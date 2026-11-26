defmodule RescueMeshWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :api do
    plug :accepts, ["json"]
    plug RescueMeshWeb.Plugs.Auth
    plug RescueMeshWeb.Plugs.RateLimit
  end

  scope "/api/v1", RescueMeshWeb do
    pipe_through :api
    get "/nodes", NodeController, :index
    get "/nodes/:id", NodeController, :show
    get "/messages", MessageController, :index
    post "/messages", MessageController, :create
    get "/status", StatusController, :show
  end

  scope "/", RescueMeshWeb do
    get "/", PageController, :home
    live "/dashboard", DashboardLive
  end
end
