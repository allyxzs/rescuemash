defmodule RescueMeshWeb.SessionController do
  use RescueMeshWeb, :controller

  def new(conn, _),
    do: render(conn, :new, error: nil, configured: is_binary(RescueMesh.Security.token_hash()))

  def create(conn, params) do
    if RescueMesh.Security.authenticate(params["token"]) do
      conn
      |> configure_session(renew: true)
      |> clear_session()
      |> put_session(:auth_hash, RescueMesh.Security.token_hash())
      |> redirect(to: "/dashboard")
    else
      conn
      |> put_status(:unauthorized)
      |> render(:new,
        error: "Token inválido. Confira sua credencial de acesso.",
        configured: is_binary(RescueMesh.Security.token_hash())
      )
    end
  end

  def delete(conn, _), do: conn |> configure_session(drop: true) |> redirect(to: "/login")
end
