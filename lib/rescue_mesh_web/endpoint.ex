defmodule RescueMeshWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :rescue_mesh

  @session_options [
    store: :cookie,
    key: "_rescuemash_v3",
    signing_salt: "session-v3",
    encryption_salt: "encrypted-session-v3",
    same_site: "Strict",
    http_only: true,
    max_age: 28_800
  ]
  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
  plug Plug.Static, at: "/", from: :rescue_mesh, only: ~w(assets favicon.svg)
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/json"],
    json_decoder: Jason,
    length: 16_384

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug RescueMeshWeb.Router
end
