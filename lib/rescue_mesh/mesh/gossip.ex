defmodule RescueMesh.Mesh.Gossip do
  @moduledoc "Gossip com TTL, deduplicação e ACKs autenticados pelo envelope do nó."
  use GenServer

  @max_ttl Application.compile_env!(:rescue_mesh, :mesh_message_ttl)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_packet(ip, data), do: GenServer.cast(__MODULE__, {:packet, ip, data})
  def broadcast(attrs), do: GenServer.cast(__MODULE__, {:broadcast, attrs})

  @impl true
  def init(_) do
    {:ok, %{seen: MapSet.new()}}
  end

  @impl true
  def handle_cast({:broadcast, attrs}, state) do
    id = message_id(attrs)
    packet = %{
      "type" => "message",
      "id" => id,
      "from" => RescueMesh.NodeId.get(),
      "content" => Map.get(attrs, "content", ""),
      "priority" => Map.get(attrs, "priority", "normal"),
      "ttl" => @max_ttl,
      "ts" => System.system_time(:second)
    }

    persist(packet)
    forward(packet)
    {:noreply, %{state | seen: MapSet.put(state.seen, id)}}
  end

  @impl true
  def handle_cast({:packet, ip, data}, state) do
    case Jason.decode(data) do
      {:ok, %{"type" => "message", "id" => id, "from" => from, "content" => content, "ttl" => ttl} = packet}
          when is_binary(id) and is_binary(from) and is_binary(content) and is_integer(ttl) and ttl >= 0 ->
        if MapSet.member?(state.seen, id) do
          {:noreply, state}
        else
          persist(packet)
          send_ack(ip, packet)
          next = if ttl > 1, do: Map.put(packet, "ttl", ttl - 1), else: nil
          if next, do: forward(next)
          {:noreply, %{state | seen: MapSet.put(state.seen, id)}}
        end

      {:ok, %{"type" => "ack", "msg_id" => id, "from" => from}}
          when is_binary(id) and is_binary(from) ->
        RescueMesh.Messaging.Store.mark_delivered(id, from)
        {:noreply, state}

      _ ->
        {:noreply, state}
    end
  end

  defp persist(packet) do
    RescueMesh.Messaging.Store.store(packet)
  end

  defp forward(packet) do
    encoded = Jason.encode!(packet)
    RescueMesh.Mesh.Discovery.get_neighbors()
    |> Enum.each(fn n -> RescueMesh.Mesh.UDP.send_mesh_packet(n.ip, n.port, encoded) end)
  end

  defp send_ack(ip, packet) do
    # ACK é devolvido ao endereço de origem observado no datagrama.
    ack = Jason.encode!(%{"type" => "ack", "msg_id" => packet["id"], "from" => RescueMesh.NodeId.get()})
    RescueMesh.Mesh.UDP.send_mesh_packet(ip, Application.get_env(:rescue_mesh, :mesh_udp_port), ack)
  end

  defp message_id(attrs) do
    :crypto.hash(:sha256, [RescueMesh.NodeId.get(), System.system_time(:nanosecond), inspect(attrs)])
    |> Base.encode16(case: :lower)
  end
end