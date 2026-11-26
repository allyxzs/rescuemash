import Config

config :rescue_mesh, RescueMesh.Repo, database: Path.expand("priv/rescue_mesh_dev.sqlite3")

config :rescue_mesh, RescueMeshWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  server: true,
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :logger, level: :debug
