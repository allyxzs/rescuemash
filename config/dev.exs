import Config

config :rescue_mesh, RescueMesh.Repo,
  username: nil,
  password: nil,
  database: "ecto_sqlite3:/priv/db/rescue_mesh.sqlite3",
  show_sql: false,
  pool_size: 10

config :rescue_mesh, RescueMesh.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
