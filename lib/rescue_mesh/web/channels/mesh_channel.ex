defmodule RescueMesh.MeshChannel do
  use Phoenix.Channel

  def join("mesh:join", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("msg:broadcast", %{"content" => content}, socket) do
    RescueMesh.Mesh.Gossip.broadcast(%{content: content, from: "web"})
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    {:noreply, socket}
  end
end