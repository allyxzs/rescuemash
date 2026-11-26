defmodule RescueMesh.Mesh.StatusController do
  @moduledoc """
  Controller para status da rede mesh.
  """
  use Phoenix.Controller

  def status(conn, _params) do
    neighbors = RescueMesh.Mesh.Node.get_neighbors()
    json(conn, %{
      node_count: length(neighbors),
      neighbors: neighbors,
      status: :ok
    })
  end
end