defmodule RescueMeshWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: RescueMeshWeb
      import Plug.Conn
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView
      import Phoenix.LiveView.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  defmacro __using__(which), do: apply(__MODULE__, which, [])
end