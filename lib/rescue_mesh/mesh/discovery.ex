defmodule RescueMesh.Mesh.Discovery do
  @moduledoc "Descoberta e tabela de vizinhos via UDP broadcast."
  use GenServer

  @interval Application.compile_env!(:rescue_mesh, :mesh_broadcast_interval_ms)
  @port Application.compile_env!(:rescue_mesh, :mesh_udp_port)

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def handle_packet(ip, data), do: GenServer.cast(__MODULE__, {:packet, ip, data})
  def get_neighbors, do: GenServer.call(__MODULE__, :neighbors)

  @impl true
  def init(_) do
    Process.send_after(self(), :broadcast, 0)
    {:ok, %{neighbors: %{}}}
  end

  @impl true
  def handle_call(:neighbors, _from, state), do: {:reply, Map.values(state.neighbors), state}

  @impl true
  def handle_cast({:packet, ip, data}, state) do
    case Jason.decode(data) do
      {:ok, %{"node_id" => id, "port" => port}} when is_binary(id) and is_integer(port) ->
        neighbor = %{node_id: id, ip: ip, port: port, last_seen: System.system_time(:second), online: true}
        {:noreply, %{state | neighbors: Map.put(state.neighbors, id, neighbor)}}
      _ -> {:noreply, state}
    end
  end

  @impl true
  def handle_info(:broadcast, state) do
    RescueMesh.Mesh.UDP.send_discovery(Jason.encode!(%{
      "node_id" => RescueMesh.NodeId.get(), "port" => @port, "ts" => System.system_time(:second)
    }))
    Process.send_after(self(), :broadcast, @interval)
    {:noreply, state}
  end
end