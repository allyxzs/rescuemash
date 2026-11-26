defmodule RescueMesh.Mesh.UDP do
  @moduledoc "Gerencia sockets UDP de descoberta e transporte mesh."
  use GenServer
  require Logger

  @discovery_port Application.compile_env!(:rescue_mesh, :mesh_discovery_port)
  @mesh_port Application.compile_env!(:rescue_mesh, :mesh_udp_port)
  @max_packet Application.compile_env!(:rescue_mesh, :mesh_max_packet_bytes)

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def send_discovery(packet), do: GenServer.cast(__MODULE__, {:discovery, packet})
  def send_mesh_packet(ip, port, packet), do: GenServer.cast(__MODULE__, {:mesh, ip, port, packet})

  @impl true
  def init(_) do
    with {:ok, discovery} <- :gen_udp.open(@discovery_port, [:binary, {:reuseaddr, true}, {:broadcast, true}]),
         {:ok, mesh} <- :gen_udp.open(@mesh_port, [:binary, {:reuseaddr, true}]) do
      {:ok, %{discovery: discovery, mesh: mesh}}
    end
  end

  @impl true
  def handle_cast({:discovery, packet}, state) do
    :gen_udp.send(state.discovery, {255, 255, 255, 255}, @discovery_port, packet)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:mesh, ip, port, packet}, state) do
    if byte_size(packet) <= @max_packet, do: :gen_udp.send(state.mesh, ip, port, packet)
    {:noreply, state}
  end

  @impl true
  def handle_info({:udp, socket, ip, _port, data}, state) when byte_size(data) <= @max_packet do
    if socket == state.discovery, do: RescueMesh.Mesh.Discovery.handle_packet(ip, data)
    if socket == state.mesh, do: RescueMesh.Mesh.Gossip.handle_packet(ip, data)
    {:noreply, state}
  end

  @impl true
  def handle_info({:udp, _socket, _ip, _port, _data}, state), do: {:noreply, state}
end