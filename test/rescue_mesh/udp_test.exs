defmodule RescueMesh.UDPTest do
  use RescueMesh.DataCase, async: false
  alias RescueMesh.Mesh.{UDP, Protocol, Gossip}
  alias RescueMesh.Messaging.Store

  setup do
    :ok = Supervisor.terminate_child(RescueMesh.Supervisor, UDP)
    {:ok, pid} = UDP.start_link(enabled: true, mesh_port: 0, discovery_port: 0)
    Process.unlink(pid)
    {:ok, peer} = :gen_udp.open(0, [:binary, active: false])

    on_exit(fn ->
      :gen_udp.close(peer)
      if Process.alive?(pid), do: GenServer.stop(pid)
      Supervisor.restart_child(RescueMesh.Supervisor, UDP)
    end)

    %{peer: peer}
  end

  test "real UDP persists a message, ACKs observed source port, rejects replay and ACKs retransmission",
       %{peer: peer} do
    packet = RescueMesh.DataCase.packet(%{"type" => "message", "ttl" => 1})
    encrypted = Protocol.encode(packet)
    :ok = :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), encrypted)
    assert {:ok, {_, _, ack}} = :gen_udp.recv(peer, 0, 2000)
    assert {:ok, %{"type" => "ack", "msg_id" => id}, _} = Protocol.decode(ack)
    assert id == packet["id"]
    assert Store.get(id).status == "received"
    :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), encrypted)
    assert {:error, :timeout} = :gen_udp.recv(peer, 0, 100)
    :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), Protocol.encode(packet))
    assert {:ok, {_, _, _}} = :gen_udp.recv(peer, 0, 2000)
    assert length(Store.recent()) == 1
  end

  test "malformed traffic leaves UDP and Gossip alive", %{peer: peer} do
    for data <- ["{}", <<>>, :crypto.strong_rand_bytes(100), String.duplicate("a", 20_000)] do
      :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), data)
    end

    probe = RescueMesh.DataCase.packet(%{"type" => "message", "ttl" => 1})
    :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), Protocol.encode(probe))
    assert {:ok, {_, _, ack}} = :gen_udp.recv(peer, 0, 2000)
    assert {:ok, %{"type" => "ack"}, _} = Protocol.decode(ack)
    assert Process.alive?(Process.whereis(UDP))
    assert Process.alive?(Process.whereis(Gossip))
  end

  test "gossip forwards once and respects the hop limit", %{peer: peer} do
    {:ok, receiver} = :gen_udp.open(0, [:binary, active: false])
    {:ok, {_, receiver_port}} = :inet.sockname(receiver)
    RescueMesh.DataCase.neighbor(receiver_port)
    packet = RescueMesh.DataCase.packet(%{"type" => "message", "ttl" => 2})
    :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), Protocol.encode(packet))
    assert {:ok, {_, _, _}} = :gen_udp.recv(peer, 0, 2000)
    assert {:ok, {_, _, forwarded}} = :gen_udp.recv(receiver, 0, 2000)
    assert {:ok, %{"ttl" => 1, "id" => id}, _} = Protocol.decode(forwarded)
    assert id == packet["id"]
    :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), Protocol.encode(packet))
    assert {:ok, {_, _, _}} = :gen_udp.recv(peer, 0, 2000)
    assert {:error, :timeout} = :gen_udp.recv(receiver, 0, 100)
    packet = RescueMesh.DataCase.packet(%{"type" => "message", "ttl" => 1})
    :gen_udp.send(peer, {127, 0, 0, 1}, UDP.port(), Protocol.encode(packet))
    assert {:ok, {_, _, _}} = :gen_udp.recv(peer, 0, 2000)
    assert {:error, :timeout} = :gen_udp.recv(receiver, 0, 100)
    :gen_udp.close(receiver)
  end
end
