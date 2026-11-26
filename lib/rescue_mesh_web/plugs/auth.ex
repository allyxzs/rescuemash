defmodule RescueMeshWeb.Plugs.Auth do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _) do
    authorized =
      case get_req_header(conn, "authorization") do
        ["Bearer " <> token] -> RescueMesh.Security.authenticate(token)
        _ -> false
      end

    if authorized do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, Jason.encode!(%{error: "unauthorized"}))
      |> halt()
    end
  end
end
