defmodule RescueMesh.Messaging.Store do
  use GenServer
  import Ecto.Query
  alias RescueMesh.{Repo, Messaging.Message}

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def store(packet), do: GenServer.call(__MODULE__, {:store, packet})
  def mark_delivered(id, node), do: GenServer.cast(__MODULE__, {:delivered, id, node})
  def pending_messages, do: GenServer.call(__MODULE__, :pending)

  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  def handle_call({:store, packet}, _from, state) do
    attrs = %{
      id: packet["id"], from_node: packet["from"], content: packet["content"],
      ttl: packet["ttl"], priority: Map.get(packet, "priority", "normal"),
      created_at: DateTime.utc_now(), delivered_to: "[]"
    }
    result = %Message{} |> Message.changeset(attrs) |> Repo.insert(on_conflict: :nothing)
    {:reply, result, state}
  end

  @impl true
  def handle_call(:pending, _from, state) do
    query = from m in Message, where: m.status == "pending", order_by: [desc: m.priority, asc: m.created_at]
    {:reply, Repo.all(query), state}
  end

  @impl true
  def handle_cast({:delivered, id, node}, state) do
    case Repo.get(Message, id) do
      nil -> :ok
      msg ->
        delivered = Jason.decode!(msg.delivered_to || "[]") |> Enum.uniq([node])
        attrs = %{delivered_to: Jason.encode!(delivered), status: "delivered"}
        msg |> Message.changeset(attrs) |> Repo.update()
    end
    {:noreply, state}
  end
end
