config :rescue_mesh, RescueMesh.Mesh.Node,
  name: :rescue_mesh_node,
  port: 4369,
  interface: :inet,
  message_ttl: 3600,
  max_message_size: 65536,
  sync_interval: 30_000,
  gossip_interval: 5_000

config :rescue_mesh, RescueMesh.Mesh.Discovery,
  enabled: true,
  broadcast_interval: 5_000,
  scan_interval: 10_000,
  ttl: 30_000

config :rescue_mesh, RescueMesh.Messaging.Store,
  path: "priv/db/rescue_mesh.sqlite3",
  pool_size: 10

config :rescue_mesh, RescueMesh.Mesh.Gossip,
  enabled: true,
  fanout: 3,
  max_hops: 5,
  anti_entropy_interval: 60_000

config :rescue_mesh, :ecto_repos, [RescueMesh.Repo]

config :rescue_mesh, RescueMesh.Repo,
  database: System.get_env("DATABASE_URL") || "ecto_sqlite3:/priv/db/rescue_mesh.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info

import_config "#{Mix.env()}.exs"
