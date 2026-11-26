import Config

config :rescue_mesh, RescueMesh.Repo,
  username: nil,
  password: nil,
  database: System.get_env("DATABASE_URL") || "ecto_sqlite3:/priv/db/rescue_mesh.sqlite3",
  show_sql: false,
  pool_size: 20

config :rescue_mesh, RescueMesh.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT") || "4000")],
  debug_errors: false,
  code_reloader: false,
  check_origin: false,
  server: true,
  watchers: []

config :logger, level: :warn
