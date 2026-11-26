defmodule RescueMeshWeb.NodeController do
  use RescueMeshWeb, :controller
  alias RescueMesh.Mesh.Discovery

  def index(conn, _) do
    nodes = Discovery.public_neighbors()
    json(conn, %{nodes: nodes, count: length(nodes)})
  end

  def show(conn, %{"id" => id}) do
    case Enum.find(Discovery.public_neighbors(), &(&1.node_id == id)) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
      node -> json(conn, node)
    end
  end
end
