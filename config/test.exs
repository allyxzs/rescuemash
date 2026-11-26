import Config

config :rescue_mesh, RescueMesh.Repo,
  database: Path.expand("priv/rescue_mesh_test.sqlite3"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :rescue_mesh, RescueMeshWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false,
  debug_errors: true,
  check_origin: false

config :logger, level: :warning
