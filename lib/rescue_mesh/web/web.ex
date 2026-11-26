defmodule RescueMesh.Web do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: RescueMesh.Web
      plug :put_view, module: RescueMesh.Web.ErrorView
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/rescue_mesh/web/templates",
        namespace: RescueMesh.Web
      # Include all helpers, functions
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def html do
    quote do
      use Phoenix.HTML
      import Phoenix.HTML.Tag, warn: false
    end
  end

  def macro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end