import Config

if config_env() == :prod do
  secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
  api_token_hash = System.fetch_env!("RESCUEMESH_API_TOKEN_HASH")

  config :rescue_mesh, :security,
    api_token_hash: api_token_hash,
    node_shared_key: System.fetch_env!("RESCUEMESH_NODE_SHARED_KEY")

  config :rescue_mesh, RescueMeshWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
    secret_key_base: secret_key_base,
    server: true
end
