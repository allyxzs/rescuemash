defmodule RescueMesh.Mesh.Node do
  @moduledoc """
  Nó de mesh responsável por descoberta, gossip e comunicação P2P.
  Cada nó tem um nome único e mantém estado de vizinhos conectados.
  """

  @behaviour :gen_server

  use GenServer

  @doc """
  Inicia um nó de mesh na rede.
  """
  def start_link(name \\ :rescue_mesh_node, opts \\ []) do
    GenServer.start_link(__MODULE__, [name, opts], name: name)
  end

  @doc """
  Obtém o nome atual do nó.
  """
  def name do
    {:via, __MODULE__, :name} || RescueMesh.Config.node_name
  end

  @doc """
  Envía uma mensagem para todos os vizinhos conhecidos.
  """
  def broadcast(message) do
    # Envia mensagem via gossip para todos os vizinhos
    RescueMesh.Mesh.Gossip.broadcast(message)
  end

  @doc """
  Busca por nós disponíveis na rede.
  """
  def discover do
    RescueMesh.Mesh.Discovery.scan()
  end

  @doc """
  Obtém lista de vizinhos conectados.
  """
  def get_neighbors do
    {:ok, RescueMesh.State.get(:neighbors) || []}
  end

  @doc """
  Adiciona um vizinho à tabela de vizinhos.
  """
  def add_neighbor(node_id, info) do
    neighbors = RescueMesh.State.get(:neighbors) || []
    neighbors = Map.put(node_id, info, neighbors)
    RescueMesh.State.put(:neighbors, neighbors)
    RescueMesh.Mesh.Gossip.broadcast({:neighbor_added, node_id, info})
  end

  @doc """
  Remove um vizinho da tabela.
  """
  def remove_neighbor(node_id) do
    neighbors = RescueMesh.State.get(:neighbors) || []
    neighbors = Map.delete(node_id, neighbors)
    RescueMesh.State.put(:neighbors, neighbors)
    RescueMesh.Mesh.Gossip.broadcast({:neighbor_removed, node_id})
  end

  @doc """
  Processa mensagem recebida de outro nó.
  """
  def handle_message(from, message) do
    case message do
      {:gossip, payload} ->
        RescueMesh.Messaging.Store.store(message, priority: :high)
        RescueMesh.Mesh.Discovery.update_neighbor(from, message)

      {:neighbor_added, node_id, info} ->
        # Atualiza estado local de vizinhos
        RescueMesh.Mesh.Node.add_neighbor(node_id, info)

      {:neighbor_removed, node_id} ->
        RescueMesh.Mesh.Node.remove_neighbor(node_id)

      _ ->
        # Mensagem geral - armazenar e retransmitir
        RescueMesh.Messaging.Store.store(message)
    end
  end

  @doc """
  Reinicia o nó com novos parâmetros.
  """
  def restart(name, opts) do
    RescueMesh.Mesh.Node.stop()
    RescueMesh.Mesh.Node.start_link(name, opts)
  end

  defp stop do
    GenServer.stop(__MODULE__)
  end
end