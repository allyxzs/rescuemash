defmodule RescueMeshWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :rescue_mesh

  socket "/live", Phoenix.LiveView.Socket
  plug Plug.Static, at: "/", from: :rescue_mesh, only: ~w(assets favicon.ico)
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], json_decoder: Jason, length: 65_536
  plug Plug.MethodOverride
  plug Plug.Head
  plug RescueMeshWeb.Router
end