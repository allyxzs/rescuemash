defmodule RescueMesh.Mesh.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RescueMesh.Mesh do
    pipe_through :api

    get "/discovery", DiscoveryController, :list
    post "/discovery/scan", DiscoveryController, :scan
    get "/status", StatusController, :status

    post "/messages", MessagingController, :create
    get "/messages", MessagingController, :index
    get "/messages/:id", MessagingController, :show
    post "/messages/:id/resend", MessagingController, :resend
  end

  # Rotas de websocket
  get "/mesh", Phoenix.Endpoint, :websocket_endpoint
end