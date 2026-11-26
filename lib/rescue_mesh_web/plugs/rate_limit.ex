defmodule RescueMeshWeb.Plugs.RateLimit do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, opts) do
    scope = Keyword.get(opts, :scope, :api)

    limit =
      Keyword.get(opts, :limit, Application.fetch_env!(:rescue_mesh, :api_rate_limit_per_minute))

    if RescueMesh.RateLimiter.allow?({scope, conn.remote_ip}, limit) do
      conn
    else
      conn
      |> put_resp_header("retry-after", "60")
      |> put_resp_content_type("application/json")
      |> send_resp(429, Jason.encode!(%{error: "rate_limited"}))
      |> halt()
    end
  end
end
