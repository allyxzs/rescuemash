defmodule RescueMeshWeb.PageController do
  use RescueMeshWeb, :controller
  def home(conn, _params), do: redirect(conn, to: "/dashboard")
end
