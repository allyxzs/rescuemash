defmodule RescueMeshWeb.DashboardTest do
  use RescueMesh.DataCase, async: false
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint RescueMeshWeb.Endpoint
  setup do
    old = Application.fetch_env!(:rescue_mesh, :security)
    hash = :crypto.hash(:sha256, :crypto.strong_rand_bytes(32)) |> Base.encode16(case: :lower)
    Application.put_env(:rescue_mesh, :security, Keyword.put(old, :api_token_hash, hash))
    on_exit(fn -> Application.put_env(:rescue_mesh, :security, old) end)
    %{conn: build_conn() |> Plug.Test.init_test_session(%{auth_hash: hash})}
  end

  test "dashboard renders and form persists a message", %{conn: conn} do
    {:ok, view, html} = live(conn, "/dashboard")
    assert html =~ "RescueMash"
    assert html =~ "Nenhuma mensagem por aqui"

    view
    |> form("#message-composer", %{content: "Equipe no ponto A", priority: "critical"})
    |> render_submit()

    assert render(view) =~ "Equipe no ponto A"
    assert [%{priority: "critical", status: "pending"}] = RescueMesh.Messaging.Store.recent()
  end

  test "HTML is escaped and invalid submissions show an error", %{conn: conn} do
    {:ok, view, _} = live(conn, "/dashboard")
    render_submit(view, "send_message", %{content: " ", priority: "normal"})
    assert render(view) =~ "2.000 caracteres"

    render_submit(view, "send_message", %{
      content: "<script>alert(1)</script>",
      priority: "normal"
    })

    assert render(view) =~ "&lt;script&gt;"
    refute render(view) =~ "<script>alert(1)</script>"
  end
end
