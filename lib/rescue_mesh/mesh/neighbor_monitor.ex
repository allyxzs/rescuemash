defmodule RescueMesh.Mesh.NeighborMonitor do
  use GenServer

  @interval Application.compile_env!(:rescue_mesh, :mesh_heartbeat_interval_ms)
  @timeout Application.compile_env!(:rescue_mesh, :mesh_neighbor_timeout_ms)

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_) do
    Process.send_after(self(), :heartbeat, 0)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:heartbeat, state) do
    packet = Jason.encode!(%{"type" => "heartbeat", "node_id" => RescueMesh.NodeId.get(), "ts" => System.system_time(:second)})
    for n <- RescueMesh.Mesh.Discovery.get_neighbors(), do: RescueMesh.Mesh.UDP.send_mesh_packet(n.ip, n.port, packet)
    Process.send_after(self(), :heartbeat, @interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(:cleanup, state), do: {:noreply, state}
end