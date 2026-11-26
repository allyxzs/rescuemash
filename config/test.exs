import Config

config :rescue_mesh,
  mesh_enabled: false,
  queue_enabled: false,
  node_id_path: Path.join(System.tmp_dir!(), "rescuemash-test-#{System.pid()}/node_id")

config :rescue_mesh, RescueMesh.Repo,
  database: Path.join(System.tmp_dir!(), "rescuemash-test-#{System.pid()}.sqlite3"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1

config :rescue_mesh, RescueMeshWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false,
  debug_errors: true,
  check_origin: false

config :logger, level: :warning
