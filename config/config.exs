import Config

config :rescue_mesh,
  ecto_repos: [RescueMesh.Repo],
  node_id_path: "data/node_id",
  mesh_udp_port: 43_690,
  mesh_discovery_port: 43_691,
  mesh_broadcast_address: {255, 255, 255, 255},
  mesh_enabled: true,
  mesh_broadcast_interval_ms: 5_000,
  mesh_neighbor_timeout_ms: 20_000,
  mesh_message_ttl: 8,
  mesh_max_packet_bytes: 16_384,
  mesh_max_retries: 3,
  queue_interval_ms: 5_000,
  queue_enabled: true,
  api_rate_limit_per_minute: 120

config :rescue_mesh, RescueMesh.Repo,
  database: Path.expand("data/rescuemash.sqlite3"),
  pool_size: 5,
  busy_timeout: 5_000,
  journal_mode: :wal

config :rescue_mesh, RescueMeshWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RescueMeshWeb.ErrorHTML, json: RescueMeshWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RescueMesh.PubSub,
  live_view: [signing_salt: "rescuemash-live-v3"]

config :phoenix, :json_library, Jason
config :phoenix, :filter_parameters, ["password", "token", "secret", "authorization"]
config :logger, :default_formatter, format: "[$level] $message\n"
import_config "#{config_env()}.exs"
