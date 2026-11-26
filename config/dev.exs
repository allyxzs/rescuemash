import Config

config :rescue_mesh, RescueMeshWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  server: true,
  debug_errors: true,
  check_origin: ["//localhost", "//127.0.0.1"]

config :logger, level: :info
