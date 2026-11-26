defmodule RescueMeshWeb.StatusController do
  use Phoenix.Controller

  def show(conn, _params) do
    json(conn, %{
      version: "2.0.0",
      node_id: RescueMesh.NodeId.get(),
      uptime: System.system_time(:second),
      nodes: length(RescueMesh.Mesh.Discovery.get_neighbors())
    })
  end
end