defmodule RescueMesh.Mesh.Gossip do
  use GenServer
  alias RescueMesh.{NodeId, Mesh.Discovery, Mesh.UDP, Messaging.Message, Messaging.Store}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def handle_packet(ip, port, data), do: GenServer.cast(__MODULE__, {:packet, ip, port, data})
  def broadcast(attrs), do: GenServer.call(__MODULE__, {:broadcast, attrs})
  def retry_pending, do: GenServer.call(__MODULE__, :retry_pending)
  @impl true
  def init(_), do: {:ok, %{}}
  @impl true
  def handle_call({:broadcast, attrs}, _from, state) do
    packet = %{
      "type" => "message",
      "id" => Ecto.UUID.generate(),
      "from" => NodeId.get(),
      "content" => Map.get(attrs, "content"),
      "priority" => Map.get(attrs, "priority", "normal"),
      "ttl" => Application.fetch_env!(:rescue_mesh, :mesh_message_ttl),
      "ts" => System.system_time(:second)
    }

    reply =
      case Store.store(packet) do
        {:ok, message, :new} -> {:ok, message}
        {:error, reason} -> {:error, reason}
      end

    {:reply, reply, state}
  end

  def handle_call(:retry_pending, _from, state) do
    neighbors = Discovery.get_neighbors()

    unless neighbors == [] do
      Enum.each(Store.pending_messages(), fn message ->
        cond do
          message.attempts >= Application.fetch_env!(:rescue_mesh, :mesh_max_retries) ->
            Store.fail(message)

          true ->
            case Store.record_attempt(message) do
              {:ok, updated} -> forward(Message.packet(updated), neighbors)
              _ -> :ok
            end
        end
      end)

      Store.notify()
    end

    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:packet, ip, port, %{"type" => "message"} = packet}, state) do
    case Store.store(packet, "received") do
      {:ok, _msg, result} ->
        # Duplicate messages are ACKed again: a previous ACK may have been lost.
        UDP.send_mesh_packet(ip, port, %{
          "type" => "ack",
          "msg_id" => packet["id"],
          "from" => NodeId.get()
        })

        if result == :new and packet["ttl"] > 1 do
          neighbors = Enum.reject(Discovery.get_neighbors(), &(&1.ip == ip and &1.port == port))
          forward(Map.update!(packet, "ttl", &(&1 - 1)), neighbors)
        end

      _ ->
        :ok
    end

    {:noreply, state}
  end

  def handle_cast({:packet, ip, port, %{"type" => "ack", "msg_id" => id, "from" => from}}, state)
      when is_binary(id) and is_binary(from) do
    if Enum.any?(
         Discovery.get_neighbors(),
         &(&1.node_id == from and &1.ip == ip and &1.port == port)
       ),
       do: Store.mark_delivered(id, from)

    {:noreply, state}
  end

  def handle_cast(_, state), do: {:noreply, state}

  defp forward(packet, neighbors),
    do: Enum.each(neighbors, &UDP.send_mesh_packet(&1.ip, &1.port, packet))
end
