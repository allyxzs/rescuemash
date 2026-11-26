defmodule RescueMesh.Mesh.Discovery do
  use GenServer
  alias RescueMesh.{NodeId, Mesh.UDP, Messaging.Store}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def observe(ip, packet), do: GenServer.cast(__MODULE__, {:observe, ip, packet})
  def get_neighbors, do: GenServer.call(__MODULE__, :neighbors)

  def public_neighbors do
    Enum.map(get_neighbors(), fn n ->
      %{node_id: n.node_id, ip: to_string(:inet.ntoa(n.ip)), port: n.port, last_seen: n.last_seen}
    end)
  end

  @impl true
  def init(_) do
    if Application.get_env(:rescue_mesh, :mesh_enabled),
      do: Process.send_after(self(), :broadcast, 1_000)

    {:ok, %{}}
  end

  @impl true
  def handle_call(:neighbors, _from, state) do
    active = prune(state)
    {:reply, Map.values(active) |> Enum.sort_by(& &1.node_id), active}
  end

  @impl true
  def handle_cast({:observe, ip, %{"type" => "hello", "node_id" => id, "port" => port}}, state)
      when is_binary(id) and byte_size(id) == 36 and is_integer(port) and port > 0 and
             port < 65_536 do
    state = prune(state)

    if id != NodeId.get() and match?({:ok, _}, Ecto.UUID.cast(id)) and
         (map_size(state) < 256 or Map.has_key?(state, id)) do
      n = %{
        node_id: id,
        ip: ip,
        port: port,
        last_seen: System.system_time(:second),
        seen_at: System.monotonic_time(:millisecond)
      }

      Store.notify()
      {:noreply, Map.put(state, id, n)}
    else
      {:noreply, state}
    end
  end

  def handle_cast(_, state), do: {:noreply, state}
  @impl true
  def handle_info(:broadcast, state) do
    UDP.send_discovery(%{"type" => "hello", "node_id" => NodeId.get(), "port" => UDP.port()})

    Process.send_after(
      self(),
      :broadcast,
      Application.fetch_env!(:rescue_mesh, :mesh_broadcast_interval_ms)
    )

    {:noreply, prune(state)}
  end

  defp prune(state) do
    now = System.monotonic_time(:millisecond)
    timeout = Application.fetch_env!(:rescue_mesh, :mesh_neighbor_timeout_ms)
    Map.reject(state, fn {_id, node} -> now - node.seen_at > timeout end)
  end
end
