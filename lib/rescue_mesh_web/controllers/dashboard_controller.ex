defmodule RescueMeshWeb.DashboardController do
  use Phoenix.Controller

  def index(conn, _params) do
    conn
    |> put_layout(html: {RescueMeshWeb.Layouts, :app})
    |> render(:index)
  end
end