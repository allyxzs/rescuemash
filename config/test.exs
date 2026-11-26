import Config

config :rescue_mesh, RescueMesh.Repo,
  username: nil,
  password: nil,
  database: "ecto_sqlite3:/priv/db/test.sqlite3",
  show_sql: false,
  pool: Ecto.Adapters.SQL.Sandbox

config :rescue_mesh, RescueMesh.Endpoint,
  http: [port: 4001],
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  server: true

config :logger, level: :warn
