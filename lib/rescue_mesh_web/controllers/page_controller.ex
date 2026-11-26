defmodule RescueMeshWeb.PageController do
  use Phoenix.Controller, put_new_layout: false

  def home(conn, _params) do
    html(conn, """
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"><title>RescueMesh</title></head>
    <body style="font-family:system-ui;background:#111;color:#eee;padding:40px">
      <h1>RescueMesh v2.0.0</h1>
      <p>Comunicação Distribuída Experimental</p>
      <a href="/dashboard" style="color:#0f0">Abrir Dashboard →</a>
    </body>
    </html>
    """)
  end
end