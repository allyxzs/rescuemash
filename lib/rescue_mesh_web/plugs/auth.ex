defmodule RescueMeshWeb.Plugs.Auth do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        expected = Application.get_env(:rescue_mesh, :security)[:api_token_hash]

        if expected && Plug.Crypto.SecureCompare.secure_compare(token, expected) do
          conn
        else
          conn
          |> send_resp(401, Jason.encode!(%{error: "unauthorized"}))
          |> halt()
        end

      _ ->
        conn
        |> send_resp(401, Jason.encode!(%{error: "missing authorization"}))
        |> halt()
    end
  end
end