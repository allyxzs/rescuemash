defmodule RescueMesh.DiscoveryTest do
  use RescueMesh.DataCase, async: false
  alias RescueMesh.Mesh.Discovery

  test "self, invalid ID and invalid ports are ignored" do
    for {id, port} <- [
          {RescueMesh.NodeId.get(), 4000},
          {Ecto.UUID.generate(), -1},
          {Ecto.UUID.generate(), 65536},
          {"bad", 4000}
        ] do
      Discovery.observe({127, 0, 0, 1}, %{"type" => "hello", "node_id" => id, "port" => port})
    end

    assert Discovery.get_neighbors() == []
  end

  test "expired neighbors disappear and public IP is a JSON string" do
    RescueMesh.DataCase.neighbor()
    assert [%{ip: "127.0.0.1"}] = Discovery.public_neighbors()

    :sys.replace_state(Discovery, fn state ->
      Map.new(state, fn {k, v} ->
        {k, %{v | seen_at: System.monotonic_time(:millisecond) - 30_000}}
      end)
    end)

    assert Discovery.get_neighbors() == []
  end
end
