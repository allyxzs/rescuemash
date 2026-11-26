defmodule RescueMesh.Web.Views.LayoutView do
  use RescueMesh.Web, :view
  alias RescueMesh.Messaging.Store
  alias RescueMesh.Mesh.Node

  def assign_messages(socket) do
    case Store.priority() do
      {:ok, messages} -> messages
      :error -> []
    end
  end

  def assign_neighbors(socket) do
    case Node.get_neighbors() do
      {:ok, neighbors} -> neighbors
      :error -> []
    end
  end
end