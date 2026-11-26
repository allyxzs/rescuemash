defmodule RescueMeshWeb.Plugs.SessionAuth do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _) do
    if RescueMesh.Security.authorized_hash?(get_session(conn, :auth_hash)) do
      conn
    else
      conn |> Phoenix.Controller.redirect(to: "/login") |> halt()
    end
  end
end
