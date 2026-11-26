defmodule RescueMesh.MessagingTest do
  use RescueMesh.DataCase, async: false
  import RescueMesh.DataCase
  alias RescueMesh.{Messaging.Store, Mesh.Gossip}

  test "broadcast persists a valid unique message and never claims early delivery" do
    assert {:ok, first} = Gossip.broadcast(%{"content" => "Olá"})
    assert {:ok, second} = Gossip.broadcast(%{"content" => "Olá"})
    refute first.id == second.id
    assert first.status == "pending"
    assert Store.get(first.id).content == "Olá"
  end

  test "invalid content and priority do not enter the queue or crash Gossip" do
    for attrs <- [
          %{"content" => "   "},
          %{"content" => String.duplicate("a", 2001)},
          %{"content" => "ok", "priority" => "other"},
          %{"content" => nil}
        ] do
      assert {:error, _} = Gossip.broadcast(attrs)
    end

    assert Store.pending_messages() == []
    assert Process.alive?(Process.whereis(Gossip))
  end

  test "deduplication persists across Gossip restart" do
    packet = packet()
    assert {:ok, _, :new} = Store.store(packet, "received")
    :ok = Supervisor.terminate_child(RescueMesh.Supervisor, Gossip)
    assert {:ok, _} = Supervisor.restart_child(RescueMesh.Supervisor, Gossip)
    assert {:ok, _, :duplicate} = Store.store(packet, "received")
    assert length(Store.recent()) == 1
  end

  test "duplicate ID with altered content is rejected" do
    p = packet()
    assert {:ok, _, :new} = Store.store(p)
    assert {:error, _} = Store.store(Map.put(p, "content", "alterada"))
    assert Store.get(p["id"]).content == p["content"]
  end

  test "priority ordering is critical then high then normal" do
    for p <- ["normal", "critical", "high"], do: Store.store(packet(%{"priority" => p}))
    assert Enum.map(Store.pending_messages(), & &1.priority) == ["critical", "high", "normal"]
  end

  test "TTL and timestamps are validated" do
    for ttl <- [0, -1, 9, "oops"] do
      assert {:error, _} = Store.store(packet(%{"ttl" => ttl}))
    end

    assert {:error, :invalid_timestamp} = Store.store(packet(%{"ts" => "now"}))
  end

  test "offline queue does not consume attempts and retries are persisted" do
    {:ok, message} = Gossip.broadcast(%{"content" => "offline"})
    Gossip.retry_pending()
    assert Store.get(message.id).attempts == 0
    neighbor()
    for _ <- 1..3, do: Gossip.retry_pending()
    assert Store.get(message.id).attempts == 3
    Gossip.retry_pending()
    assert Store.get(message.id).status == "failed"
    assert {:ok, retried} = Store.retry(message.id)
    assert retried.attempts == 0
    assert retried.status == "pending"
  end

  test "ACK source must match a discovered node and actual port" do
    node = neighbor()
    {:ok, message} = Gossip.broadcast(%{"content" => "ack"})
    Gossip.retry_pending()
    ack = %{"type" => "ack", "msg_id" => message.id, "from" => node}
    Gossip.handle_packet({127, 0, 0, 1}, 45679, ack)
    :sys.get_state(Gossip)
    assert Store.get(message.id).status == "pending"
    Gossip.handle_packet({127, 0, 0, 1}, 45678, ack)
    :sys.get_state(Gossip)
    assert Store.get(message.id).status == "delivered"
    Gossip.handle_packet({127, 0, 0, 1}, 45678, ack)
    :sys.get_state(Gossip)
    assert Jason.decode!(Store.get(message.id).delivered_to) == [node]
  end

  test "messages are JSON serializable" do
    {:ok, message} = Gossip.broadcast(%{"content" => "JSON"})
    assert Jason.decode!(Jason.encode!(message))["content"] == "JSON"
  end
end
