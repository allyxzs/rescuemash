defmodule RescueMeshWeb.APITest do
  use RescueMesh.DataCase, async: false
  import Plug.Test
  import Plug.Conn
  alias RescueMeshWeb.Endpoint

  setup do
    old = Application.fetch_env!(:rescue_mesh, :security)
    token = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
    hash = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
    Application.put_env(:rescue_mesh, :security, Keyword.put(old, :api_token_hash, hash))
    on_exit(fn -> Application.put_env(:rescue_mesh, :security, old) end)
    %{token: token, hash: hash}
  end

  defp request(method, path, token, body \\ nil) do
    conn(method, path, body && Jason.encode!(body))
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "Bearer " <> token)
    |> Endpoint.call(Endpoint.init([]))
  end

  test "token is hashed, the stored hash is not itself a credential", %{token: token, hash: hash} do
    assert request(:get, "/api/v1/status", token).status == 200
    assert request(:get, "/api/v1/status", hash).status == 401
    assert request(:get, "/api/v1/status", "wrong").status == 401
  end

  test "API returns meaningful validation, status and history", %{token: token} do
    assert request(:post, "/api/v1/messages", token, %{}).status == 400
    assert request(:post, "/api/v1/messages", token, %{content: " "}).status == 422
    conn = request(:post, "/api/v1/messages", token, %{content: "API", priority: "high"})
    assert conn.status == 201
    id = Jason.decode!(conn.resp_body)["message"]["id"]
    conn = request(:get, "/api/v1/messages", token)
    assert [%{"id" => ^id}] = Jason.decode!(conn.resp_body)["messages"]
    assert request(:get, "/api/v1/messages?limit=999999", token).status == 400
    assert request(:post, "/api/v1/messages/#{id}/retry", token, %{}).status == 409
  end

  test "rate limit is enforced with Retry-After", %{token: token} do
    for _ <- 1..120, do: assert(request(:get, "/api/v1/status", token).status == 200)
    conn = request(:get, "/api/v1/status", token)
    assert conn.status == 429
    assert get_resp_header(conn, "retry-after") == ["60"]
  end

  test "dashboard requires authentication and health is public" do
    assert request(:get, "/dashboard", "").status == 302
    assert request(:get, "/health", "").status == 200
  end

  test "login POST without CSRF is rejected", %{token: token} do
    conn = conn(:post, "/login", %{token: token})

    assert_raise Plug.CSRFProtection.InvalidCSRFTokenError, fn ->
      Endpoint.call(conn, Endpoint.init([]))
    end
  end

  test "node endpoints serialize network addresses", %{token: token} do
    id = RescueMesh.DataCase.neighbor()
    conn = request(:get, "/api/v1/nodes/#{id}", token)
    assert Jason.decode!(conn.resp_body)["ip"] == "127.0.0.1"
  end
end
