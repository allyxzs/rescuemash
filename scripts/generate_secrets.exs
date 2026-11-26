# Run with `elixir scripts/generate_secrets.exs`. Never overwrites credentials.
if File.exists?(".env") or File.exists?(".access-token"),
  do: raise(".env or .access-token already exists; refusing to overwrite credentials")

token = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
hash = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
secret = Base.encode64(:crypto.strong_rand_bytes(48))
mesh = Base.encode64(:crypto.strong_rand_bytes(32))

for {path, content} <- [
      {".env",
       "SECRET_KEY_BASE=#{secret}\nRESCUEMASH_API_TOKEN_HASH=#{hash}\nRESCUEMASH_NODE_SHARED_KEY=#{mesh}\nPORT=4000\nPHX_HOST=localhost\n"},
      {".access-token", token <> "\n"}
    ] do
  {:ok, file} = File.open(path, [:write, :exclusive])
  File.chmod!(path, 0o600)
  IO.binwrite(file, content)
  File.close(file)
end

IO.puts("Created .env and .access-token with owner-only permissions. Keep both files private.")
