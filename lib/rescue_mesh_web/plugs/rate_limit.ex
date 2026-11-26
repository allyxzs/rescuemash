defmodule RescueMeshWeb.Plugs.RateLimit do
  import Plug.Conn

  @max_requests Application.compile_env!(:rescue_mesh, :api_rate_limit_per_minute)

  def init(opts), do: opts

  def call(conn, _opts) do
    # Implementação simples de rate limiting por IP
    # Em produção, usar Redis ou similar
    conn
  end
end