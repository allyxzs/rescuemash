defmodule RescueMesh.Messaging.Store do
  import Ecto.Query
  alias RescueMesh.{Repo, Messaging.Message}

  def store(packet, status \\ "pending") do
    timestamp = packet["ts"]

    with true <-
           is_integer(timestamp) and timestamp >= 0 and
             timestamp <= System.system_time(:second) + 120,
         {:ok, created_at} <- DateTime.from_unix(timestamp) do
      attrs = %{
        id: packet["id"],
        from_node: packet["from"],
        content: packet["content"],
        ttl: packet["ttl"],
        priority: Map.get(packet, "priority", "normal"),
        created_at: created_at,
        status: status
      }

      changeset = Message.changeset(%Message{}, attrs)

      case Repo.insert(changeset) do
        {:ok, message} ->
          notify()
          {:ok, message, :new}

        {:error, invalid} ->
          existing = if changeset.valid?, do: Repo.get(Message, packet["id"])

          if existing && existing.from_node == attrs.from_node &&
               existing.content == attrs.content &&
               existing.priority == attrs.priority && existing.created_at == attrs.created_at do
            {:ok, existing, :duplicate}
          else
            {:error, invalid}
          end
      end
    else
      _ -> {:error, :invalid_timestamp}
    end
  end

  def pending_messages(limit \\ 100) do
    Repo.all(
      from m in Message,
        where: m.status == "pending",
        order_by: [
          asc: fragment("CASE priority WHEN 'critical' THEN 0 WHEN 'high' THEN 1 ELSE 2 END"),
          asc: m.created_at
        ],
        limit: ^limit
    )
  end

  def recent(limit \\ 50),
    do: Repo.all(from m in Message, order_by: [desc: m.inserted_at, desc: m.id], limit: ^limit)

  def counts do
    counts =
      Repo.all(from m in Message, group_by: m.status, select: {m.status, count(m.id)})
      |> Map.new()

    Map.merge(%{"pending" => 0, "delivered" => 0, "received" => 0, "failed" => 0}, counts)
  end

  def get(id), do: Repo.get(Message, id)

  def mark_delivered(id, node) do
    # Called serially by Gossip; the transaction keeps status and receipts together.
    Repo.transaction(fn ->
      case Repo.get(Message, id) do
        %Message{status: status, attempts: attempts} = msg
        when status in ["pending", "failed", "delivered"] and attempts > 0 ->
          delivered = Enum.uniq([node | Jason.decode!(msg.delivered_to)])

          msg
          |> Message.changeset(%{delivered_to: Jason.encode!(delivered), status: "delivered"})
          |> Repo.update!()

        _ ->
          :ignored
      end
    end)

    notify()
  end

  def record_attempt(msg) do
    msg
    |> Message.changeset(%{
      attempts: msg.attempts + 1,
      last_attempt_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> Repo.update()
  end

  def fail(msg), do: msg |> Message.changeset(%{status: "failed"}) |> Repo.update()

  def retry(id) do
    case get(id) do
      %Message{status: "failed"} = msg ->
        result =
          msg
          |> Message.changeset(%{status: "pending", attempts: 0, last_attempt_at: nil})
          |> Repo.update()

        notify()
        result

      nil ->
        {:error, :not_found}

      _ ->
        {:error, :not_failed}
    end
  end

  def notify, do: Phoenix.PubSub.broadcast(RescueMesh.PubSub, "mesh:updates", :refresh)
end
