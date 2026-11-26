defmodule RescueMesh.Web.Channels.MeshChannelController do
  use RescueMesh.Web, :controller

  def join("mesh:join", _params, socket) do
    # Adiciona nó à rede mesh
    RescueMesh.Mesh.Node.add_neighbor(socket.assigns.node_id, %{ip: socket.assigns.ip, port: socket.assigns.port})
    {:ok, socket}
  end

  def handle_in("msg:broadcast", %{"content" => content}, socket) do
    # Broadcasting via gossip protocol
    RescueMesh.Mesh.Gossip.broadcast(%{content: content, from: socket.assigns.node_id})
    {:noreply, socket}
  end

  def handle_in("msg:direct", %{"target" => target, "content" => content}, socket) do
    # Mensagem direta para um nó específico
    RescueMesh.Mesh.Gossip.send_message_to(target, %{"content" => content, "from" => socket.assigns.node_id})
    {:noreply, socket}
  end

  def handle_info({:delivered, msg_id}, socket) do
    # Atualiza status de entrega
    RescueMesh.Messaging.Store.delivered_by_id(msg_id)
    {:noreply, socket}
  end
end