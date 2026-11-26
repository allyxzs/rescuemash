defmodule RescueMeshWeb do
  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json], layouts: [html: RescueMeshWeb.Layouts]
      import Plug.Conn
    end
  end

  defmacro __using__(which), do: apply(__MODULE__, which, [])
end
