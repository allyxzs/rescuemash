defmodule RescueMesh.MeshTest do
  use ExUnit.Case, async: true

  test "ttl configuration is bounded" do
    ttl = Application.fetch_env!(:rescue_mesh, :mesh_message_ttl)
    assert ttl > 0
    assert ttl <= 64
  end
end
