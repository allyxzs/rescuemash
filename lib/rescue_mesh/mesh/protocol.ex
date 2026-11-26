defmodule RescueMesh.Mesh.Protocol do
  @moduledoc "Versioned AES-256-GCM envelope. All members of a mesh share one key."
  @aad "RescueMash/v3"
  @max_bytes 16_384
  def encode(payload, key \\ key()) do
    nonce = :crypto.strong_rand_bytes(12)
    plaintext = Jason.encode!(%{"sent_at" => System.system_time(:second), "payload" => payload})

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key, nonce, plaintext, @aad, 16, true)

    <<3, nonce::binary-size(12), tag::binary-size(16), ciphertext::binary>>
  end

  def decode(data, key \\ key())

  def decode(<<3, nonce::binary-size(12), tag::binary-size(16), ciphertext::binary>> = data, key)
      when byte_size(data) <= @max_bytes do
    with plaintext when is_binary(plaintext) <-
           :crypto.crypto_one_time_aead(:aes_256_gcm, key, nonce, ciphertext, @aad, tag, false),
         {:ok, %{"sent_at" => ts, "payload" => payload}} <- Jason.decode(plaintext),
         true <- is_integer(ts) and abs(System.system_time(:second) - ts) <= 120,
         true <- is_map(payload) do
      {:ok, payload, nonce}
    else
      _ -> {:error, :invalid_packet}
    end
  end

  def decode(_, _), do: {:error, :invalid_packet}

  defp key,
    do: Application.fetch_env!(:rescue_mesh, :security) |> Keyword.fetch!(:node_shared_key)
end
