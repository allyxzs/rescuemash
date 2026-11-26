defmodule RescueMesh.Security do
  def token_hash, do: Application.get_env(:rescue_mesh, :security, [])[:api_token_hash]

  def authenticate(token) when is_binary(token) and byte_size(token) <= 512 do
    digest = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
    authorized_hash?(digest)
  end

  def authenticate(_), do: false

  def authorized_hash?(hash) do
    expected = token_hash()

    is_binary(hash) and is_binary(expected) and byte_size(expected) == 64 and
      byte_size(hash) == 64 and Plug.Crypto.secure_compare(hash, expected)
  end
end
