defmodule RescueMesh.Mesh.DiscoveryController do
  @moduledoc """
  Controller para descoberta de nós na rede mesh.
  """
  use Phoenix.Controller

  def list(conn, _params) do
    neighbors = RescueMesh.Mesh.Node.get_neighbors()
    json(conn, %{neighbors: neighbors, count: length(neighbors)})
  end

  def scan(conn, _params) do
    RescueMesh.Mesh.Discovery.scan()
    json(conn, %{status: "scan_started"})
  end
end