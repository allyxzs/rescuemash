defmodule RescueMesh.ProtocolTest do
  use ExUnit.Case, async: true
  alias RescueMesh.Mesh.Protocol

  test "authenticated encrypted round trip and random nonces" do
    key = :crypto.strong_rand_bytes(32)
    data = %{"type" => "hello", "content" => "private content"}
    encoded = Protocol.encode(data, key)
    refute encoded =~ "private content"
    refute encoded == Protocol.encode(data, key)
    assert {:ok, ^data, nonce} = Protocol.decode(encoded, key)
    assert byte_size(nonce) == 12
  end

  test "tampered packets, wrong keys and oversized packets are rejected" do
    key = :crypto.strong_rand_bytes(32)
    encoded = Protocol.encode(%{"content" => "test"}, key)
    <<first, rest::binary>> = encoded
    assert {:error, _} = Protocol.decode(<<Bitwise.bxor(first, 1), rest::binary>>, key)
    assert {:error, _} = Protocol.decode(encoded, :crypto.strong_rand_bytes(32))
    assert {:error, _} = Protocol.decode(String.duplicate("x", 20_000), key)
    assert {:error, _} = Protocol.decode("not JSON", key)
  end

  test "expired authenticated envelopes are rejected" do
    key = :crypto.strong_rand_bytes(32)
    nonce = :crypto.strong_rand_bytes(12)
    plain = Jason.encode!(%{"sent_at" => System.system_time(:second) - 121, "payload" => %{}})

    {cipher, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key, nonce, plain, "RescueMash/v3", 16, true)

    assert {:error, _} = Protocol.decode(<<3, nonce::binary, tag::binary, cipher::binary>>, key)
  end
end
