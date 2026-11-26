defmodule RescueMesh.Web.Controllers.MessagingController do
  use Phoenix.Controller

  @doc """
  Cria uma nova mensagem.
  """
  def create(conn, %{"content" => content, "priority" => priority}) do
    case RescueMesh.Messaging.Store.store(content, priority: priority || "normal") do
      {:ok, message} ->
        RescueMesh.Mesh.Gossip.broadcast(%{
          content: message.content,
          id: message.id,
          from: "mesh-node"
        })
        json(conn, %{status: "sent", id: message.id})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Failed to store message"})
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Content required"})
  end

  def index(conn, _params) do
    messages = RescueMesh.Messaging.Store.priority()
    json(conn, %{messages: messages, count: length(messages)})
  end

  def show(conn, %{"id" => id}) do
    case RescueMesh.Messaging.Message.get_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Message not found"})

      message ->
        json(conn, %{message: message})
    end
  end

  def resend(conn, %{"id" => id}) do
    case RescueMesh.Messaging.Message.get_by_id(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Message not found"})

      message ->
        # Re-enviar via gossip
        RescueMesh.Mesh.Gossip.broadcast(%{
          content: message.content,
          id: message.id,
          from: "resync"
        })
        json(conn, %{status: "resent", id: message.id})
    end
  end
end