import Config
prod? = config_env() == :prod

secret =
  System.get_env("SECRET_KEY_BASE") ||
    if(!prod?, do: Base.encode64(:crypto.strong_rand_bytes(48)))

token_hash =
  System.get_env("RESCUEMASH_API_TOKEN_HASH") || System.get_env("RESCUEMESH_API_TOKEN_HASH")

key = System.get_env("RESCUEMASH_NODE_SHARED_KEY") || System.get_env("RESCUEMESH_NODE_SHARED_KEY")

if prod? and (!is_binary(secret) or byte_size(secret) < 64),
  do: raise("SECRET_KEY_BASE must have at least 64 bytes")

if prod? and (!is_binary(token_hash) or !Regex.match?(~r/\A[0-9a-f]{64}\z/, token_hash)),
  do: raise("RESCUEMASH_API_TOKEN_HASH must be a lowercase SHA-256 hex digest")

mesh_key =
  case key && Base.decode64(key) do
    {:ok, bytes} when byte_size(bytes) == 32 -> bytes
    nil when not prod? -> :crypto.strong_rand_bytes(32)
    _ -> raise "RESCUEMASH_NODE_SHARED_KEY must be a base64-encoded 32-byte key"
  end

config :rescue_mesh, :security, api_token_hash: token_hash, node_shared_key: mesh_key
config :rescue_mesh, RescueMeshWeb.Endpoint, secret_key_base: secret

if config_env() != :test do
  {:ok, broadcast_ip} =
    :inet.parse_ipv4_address(
      String.to_charlist(System.get_env("MESH_BROADCAST_ADDRESS", "255.255.255.255"))
    )

  config :rescue_mesh, mesh_broadcast_address: broadcast_ip
  data_dir = Path.expand(System.get_env("DATA_DIR", "data"))

  config :rescue_mesh,
    node_id_path: Path.join(data_dir, "node_id"),
    mesh_udp_port: String.to_integer(System.get_env("MESH_PORT", "43690")),
    mesh_discovery_port: String.to_integer(System.get_env("DISCOVERY_PORT", "43691"))

  config :rescue_mesh, RescueMesh.Repo, database: Path.join(data_dir, "rescuemash.sqlite3")

  config :rescue_mesh, RescueMeshWeb.Endpoint,
    http: [
      ip: if(prod?, do: {0, 0, 0, 0}, else: {127, 0, 0, 1}),
      port: String.to_integer(System.get_env("PORT", "4000"))
    ],
    url: [
      host: System.get_env("PHX_HOST", "localhost"),
      port: String.to_integer(System.get_env("PORT", "4000"))
    ],
    check_origin: ["//#{System.get_env("PHX_HOST", "localhost")}", "//localhost", "//127.0.0.1"],
    server: true
end
