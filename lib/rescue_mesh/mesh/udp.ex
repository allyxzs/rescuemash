defmodule RescueMesh.Mesh.UDP do
  use GenServer
  alias RescueMesh.Mesh.{Discovery, Gossip, Protocol}
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  def port, do: GenServer.call(__MODULE__, :port)
  def send_discovery(packet), do: GenServer.cast(__MODULE__, {:discovery, packet})

  def send_mesh_packet(ip, port, packet),
    do: GenServer.cast(__MODULE__, {:mesh, ip, port, packet})

  @impl true
  def init(opts) do
    if Keyword.get(opts, :enabled, Application.get_env(:rescue_mesh, :mesh_enabled)) do
      discovery_port =
        Keyword.get(
          opts,
          :discovery_port,
          Application.fetch_env!(:rescue_mesh, :mesh_discovery_port)
        )

      mesh_port =
        Keyword.get(opts, :mesh_port, Application.fetch_env!(:rescue_mesh, :mesh_udp_port))

      with {:ok, discovery} <-
             :gen_udp.open(discovery_port, [
               :binary,
               active: :once,
               reuseaddr: true,
               broadcast: true
             ]),
           {:ok, mesh} <- :gen_udp.open(mesh_port, [:binary, active: :once]) do
        {:ok, %{discovery: discovery, mesh: mesh, seen: %{}}}
      end
    else
      {:ok, %{discovery: nil, mesh: nil, seen: %{}}}
    end
  end

  @impl true
  def handle_call(:port, _from, %{mesh: nil} = state), do: {:reply, 0, state}

  def handle_call(:port, _from, state) do
    {:ok, {_ip, port}} = :inet.sockname(state.mesh)
    {:reply, port, state}
  end

  @impl true
  def handle_cast({:discovery, packet}, state) do
    send_packet(
      state.discovery,
      Application.fetch_env!(:rescue_mesh, :mesh_broadcast_address),
      Application.fetch_env!(:rescue_mesh, :mesh_discovery_port),
      packet
    )

    {:noreply, state}
  end

  def handle_cast({:mesh, ip, port, packet}, state) do
    send_packet(state.mesh, ip, port, packet)
    {:noreply, state}
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    now = System.monotonic_time(:second)
    seen = Map.reject(state.seen, fn {_nonce, time} -> now - time > 240 end)

    seen =
      case Protocol.decode(data) do
        {:ok, payload, nonce} ->
          if Map.has_key?(seen, nonce) or map_size(seen) >= 20_000 do
            seen
          else
            cond do
              socket == state.discovery -> Discovery.observe(ip, payload)
              socket == state.mesh -> Gossip.handle_packet(ip, port, payload)
              true -> :ok
            end

            Map.put(seen, nonce, now)
          end

        _ ->
          seen
      end

    :inet.setopts(socket, active: :once)
    {:noreply, %{state | seen: seen}}
  end

  def handle_info(_, state), do: {:noreply, state}
  @impl true
  def terminate(_reason, state) do
    for socket <- [state.discovery, state.mesh], socket != nil, do: :gen_udp.close(socket)
    :ok
  end

  defp send_packet(nil, _, _, _), do: :ok

  defp send_packet(socket, ip, port, packet) do
    data = Protocol.encode(packet)

    if byte_size(data) <= Application.fetch_env!(:rescue_mesh, :mesh_max_packet_bytes),
      do: :gen_udp.send(socket, ip, port, data)
  end
end
