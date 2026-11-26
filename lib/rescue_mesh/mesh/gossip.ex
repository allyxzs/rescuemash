defmodule RescueMesh.Mesh.Gossip do
  @moduledoc """
  Protocolo gossip para disseminar mensagens através da rede mesh.
  Propaga mensagens de nó em nó com TTL e priorização.
  """

  @doc """
  Broadcast uma mensagem para todos os vizinhos.
  """
  def broadcast(message) do
    neighbors = RescueMesh.Mesh.Node.get_neighbors()
    for node <- neighbors do
      send_message_to(node, message)
    end
  end

  @doc """
  Envia mensagem para um nó específico.
  """
  def send_message_to(node_id, message) do
    # Simula envio P2P
    case RescueMesh.Messaging.Store.store(message, priority: :normal) do
      {:ok, _} ->
        # Marca como enviado para este nó
        RescueMesh.State.put(:sent_to, Map.put(RescueMesh.State.get(:sent_to) || %{}, node_id, System.system_time(:second)))
        :ok
      error ->
        error
    end
  end

  @doc """
  Propaga mensagem via gossip (um nó por vez).
  """
  def propagate(message, hops \\ 0) when hops < 5 do
    neighbors = RescueMesh.Mesh.Node.get_neighbors()
    # Filtra quem já recebeu esta mensagem
    unreceived = Filter.filter(neighbors, fn node ->
      not RescueMesh.Messaging.Store.received?(message, node)
    end)

    if length(unreceived) > 0 do
      target = List.first(unreceived)
      send_message_to(target, message)
      # Marca como recebido por este nó
      RescueMesh.Messaging.Store.mark_received(message, target)
      # Continua propagação
      propagate(message, hops + 1)
    else
      # Nenhum novo nó para propagar
      :ok
    end
  end

  @doc """
  Verifica se mensagem foi recebida por um nó.
  """
  def received?(message, node_id) do
    RescueMesh.Messaging.Store.has_received?(message, node_id)
  end

  @doc """
  Reinicia protocolo gossip.
  """
  def restart do
    # Zera estado interno se necessário
    RescueMesh.State.put(:gossip_round, 0)
  end
end