defmodule RescueMesh.Web.Controllers.PageController do
  use Phoenix.Controller

  def home(conn, _params) do
    neighbors = RescueMesh.Mesh.Node.get_neighbors()
    json(conn, %{
      message: "RescueMesh - Comunicação Distribuída para Emergências",
      version: "1.0.0",
      nodes: length(neighbors),
      neighbors: neighbors
    })
  end
end