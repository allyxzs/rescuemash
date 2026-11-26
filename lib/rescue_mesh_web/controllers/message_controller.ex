defmodule RescueMeshWeb.MessageController do
  use RescueMeshWeb, :controller
  alias RescueMesh.{NodeId, Mesh.Gossip, Messaging.Store}

  def index(conn, _params), do: json(conn, %{messages: Store.pending_messages()})

  def create(conn, %{"content" => content} = params) when is_binary(content) do
    Gossip.broadcast(%{"content" => content, "priority" => Map.get(params, "priority", "normal"), "from" => NodeId.get()})
    json(conn, %{status: "queued"})
  end

  def create(conn, _params), do: conn |> put_status(:bad_request) |> json(%{error: "content_required"})
end
