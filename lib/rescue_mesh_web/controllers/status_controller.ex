defmodule RescueMeshWeb.StatusController do
  use RescueMeshWeb, :controller

  def show(conn, _) do
    {uptime, _} = :erlang.statistics(:wall_clock)

    json(conn, %{
      name: "RescueMash v3",
      version: "3.0.0",
      node_id: RescueMesh.NodeId.get(),
      uptime_seconds: div(uptime, 1_000),
      nodes: length(RescueMesh.Mesh.Discovery.get_neighbors()),
      messages: RescueMesh.Messaging.Store.counts(),
      transport: "AES-256-GCM"
    })
  end

  def health(conn, _) do
    case Ecto.Adapters.SQL.query(RescueMesh.Repo, "SELECT 1 FROM messages LIMIT 1", []) do
      {:ok, _} -> json(conn, %{status: "ok", version: "3.0.0"})
      _ -> conn |> put_status(:service_unavailable) |> json(%{status: "unavailable"})
    end
  end
end
