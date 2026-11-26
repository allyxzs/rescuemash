defmodule RescueMeshWeb.MessageController do
  use RescueMeshWeb, :controller
  alias RescueMesh.{Mesh.Gossip, Messaging.Store}

  def index(conn, params) do
    value = Map.get(params, "limit", "50")
    parsed = if is_binary(value), do: Integer.parse(value), else: :error

    case parsed do
      {limit, ""} when limit in 1..100 -> json(conn, %{messages: Store.recent(limit)})
      _ -> conn |> put_status(:bad_request) |> json(%{error: "limit_must_be_1_to_100"})
    end
  end

  def create(conn, %{"content" => content} = params) when is_binary(content) do
    case Gossip.broadcast(Map.take(params, ["content", "priority"])) do
      {:ok, message} ->
        conn |> put_status(:created) |> json(%{status: "queued", message: message})

      {:error, %Ecto.Changeset{} = changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid_message", fields: errors})

      {:error, _} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "invalid_message"})
    end
  end

  def create(conn, _), do: conn |> put_status(:bad_request) |> json(%{error: "content_required"})

  def retry(conn, %{"id" => id}) do
    case Store.retry(id) do
      {:ok, message} -> json(conn, %{message: message})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
      {:error, _} -> conn |> put_status(:conflict) |> json(%{error: "message_not_failed"})
    end
  end
end
