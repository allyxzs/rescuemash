import Config

config :rescue_mesh,
  ecto_repos: [RescueMesh.Repo],
  node_id_path: "priv/node_id",
  mesh_udp_port: 43_690,
  mesh_discovery_port: 43_691,
  mesh_broadcast_interval_ms: 5_000,
  mesh_heartbeat_interval_ms: 5_000,
  mesh_neighbor_timeout_ms: 20_000,
  mesh_message_ttl: 8,
  mesh_max_packet_bytes: 65_536,
  mesh_max_retries: 3,
  api_max_body_bytes: 65_536,
  api_rate_limit_per_minute: 120

config :rescue_mesh, RescueMesh.Repo,
  database: Path.expand("priv/rescue_mesh.sqlite3"),
  pool_size: 5,
  busy_timeout: 5_000

config :rescue_mesh, RescueMeshWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [json: RescueMeshWeb.ErrorJSON], layout: false],
  pubsub_server: RescueMesh.PubSub,
  live_view: [signing_salt: "change-me-in-runtime"]

config :phoenix, :json_library, Jason
config :logger, :console, format: "[$level] $message\n"

import_config "#{config_env()}.exs"
