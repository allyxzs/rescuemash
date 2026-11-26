defmodule RescueMeshWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
    plug RescueMeshWeb.Plugs.RateLimit
    plug RescueMeshWeb.Plugs.Auth
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
    }

    plug :put_root_layout, html: {RescueMeshWeb.Layouts, :root}
  end

  pipeline :login_limit do
    plug RescueMeshWeb.Plugs.RateLimit, scope: :login, limit: 10
  end

  pipeline :authenticated do
    plug RescueMeshWeb.Plugs.SessionAuth
  end

  scope "/api/v1", RescueMeshWeb do
    pipe_through :api
    get "/nodes", NodeController, :index
    get "/nodes/:id", NodeController, :show
    get "/messages", MessageController, :index
    post "/messages", MessageController, :create
    post "/messages/:id/retry", MessageController, :retry
    get "/status", StatusController, :show
  end

  scope "/", RescueMeshWeb do
    pipe_through :browser
    get "/", PageController, :home
    get "/login", SessionController, :new
    delete "/logout", SessionController, :delete
  end

  scope "/", RescueMeshWeb do
    pipe_through [:browser, :login_limit]
    post "/login", SessionController, :create
  end

  scope "/", RescueMeshWeb do
    pipe_through [:browser, :authenticated]

    live_session :authenticated, on_mount: [RescueMeshWeb.Live.Auth] do
      live "/dashboard", DashboardLive
    end
  end

  get "/health", RescueMeshWeb.StatusController, :health
end
