defmodule RescueMeshWeb.Layouts do
  use Phoenix.Component

  def app(assigns) do
    ~H"""
    {@inner_content}
    """
  end

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="pt-BR">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <title>RescueMash v3 · Central de comunicação</title>
        <link rel="icon" href="/favicon.svg" />
        <link rel="stylesheet" href="/assets/app.css" />
        <script defer src="/assets/phoenix.js">
        </script>
        <script defer src="/assets/phoenix_live_view.js">
        </script>
        <script defer src="/assets/app.js">
        </script>
      </head>
      <body>{@inner_content}</body>
    </html>
    """
  end
end
