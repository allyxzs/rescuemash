defmodule RescueMesh.Endpoint do
  use Phoenix.Endpoint, otp_app: :rescue_mesh

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    json_decoder: Jason.Decoder,
    length: 2_000_000

  plug Plug.RequestId
  plug Plug.Logger

  # Serve at static files from "priv/static"
  # Serve at GET /  from Phoenix.Router

  # Do not log healthcheck requests
  plug Plug.MethodOverride, exceptions: [~w(patch delete)]

  # Allow CORS if needed
  # plug Plug.CORS, origins: "*", allow_headers: ["*"]"

  # Expose APIs under "/api"
  scope "/api" do
    pipe_through :api

    forward "/mesh/discovery", RescueMesh.Mesh.DiscoveryController
    forward "/mesh/messages", RescueMesh.MessagingController
    forward "/mesh/status", RescueMesh.StatusController
  end

  # Expose websocket endpoint for real-time mesh communication
  socket "/mesh" do
    channel RescueMesh.MeshChannel
  end
end