defmodule RescueMesh.Mesh.Discovery do
  @moduledoc """
  Descobridor de nós na rede local.
  Utiliza UDP broadcast para encontrar outros nós e mantém lista de vizinhos.
  """

  use GenServer

  @doc """
  Inicia o serviço de descoberta.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Força uma varredura imediata de nós.
  """
  def scan do
    GenServer.cast(__MODULE__, :scan)
  end

  @doc """
  Atualiza informações de um vizinho.
  """
  def update_neighbor(from, message) do
    last_seen = RescueMesh.State.get(:last_seen) || %{}
    last_seen = Map.put(last_seen, from, System.system_time(:second))
    RescueMesh.State.put(:last_seen, last_seen)
  end

  @impl true
  def init(opts) do
    schedule_broadcast()
    schedule_scan()
    {:ok, %{nodes: %{}, broadcast_socket: nil}}
  end

  @impl true
  def handle_info(:broadcast, state) do
    broadcast_discovery()
    schedule_broadcast()
    {:noreply, state}
  end

  @impl true
  def handle_info(:scan, state) do
    last_seen = RescueMesh.State.get(:last_seen) || %{}
    now = System.system_time(:second)
    ttl = 30_000

    active = Map.filter(last_seen, fn {_, ts} -> now - ts < ttl end)

    RescueMesh.State.put(:neighbors, Map.keys(active))
    schedule_scan()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:scan, state) do
    handle_info(:scan, state)
    {:noreply, state}
  end

  defp broadcast_discovery do
    # Simula broadcast de descoberta
    node_id = "node-#{System.system_time(:nanosecond)}"
    RescueMesh.Mesh.Node.add_neighbor(node_id, %{ip: "127.0.0.1", port: 4001})
  end

  defp schedule_broadcast do
    Process.send_after(self(), :broadcast, 5_000)
  end

  defp schedule_scan do
    Process.send_after(self(), :scan, 10_000)
  end
end