defmodule RescueMesh.Messaging.Store do
  @moduledoc """
  Armazenamento local de mensagens com persistência SQLite.
  Gerencia filas de mensagens por prioridade e histórico de recebimento.
  """

  @doc """
  Armazena uma mensagem no banco de dados local.
  """
  def store(content, \\ []) do
    priority = Keyword.get(priority, :normal)
    now = NaiveDateTime.utc_now()

    %RescueMesh.Messaging.Message{
      content: content,
      priority: priority,
      status: "pending",
      created_at: now,
      delivered_at: nil,
      received_by: []
    }
    |> RescueMesh.Messaging.Message.changeset(%{content: content, priority: priority})
    |> RescueMesh.Repo.insert()
  end

  @doc """
  Obtém todas as mensagens pendentes.
  """
  def pending do
    RescueMesh.Repo.all(
      from m in RescueMesh.Messaging.Message,
      where: m.status == "pending",
      order_by: [asc: m.priority, asc: m.created_at]
    )
  end

  @doc """
  Atualiza status de mensagem como entregue.
  """
  def delivered(%RescueMesh.Messaging.Message{} = message) do
    message
    |> change_status("delivered")
    |> RescueMesh.Repo.update()
  end

  @doc """
  Marca mensagem como recebida por um nó específico.
  """
  def received_by(%RescueMesh.Messaging.Message{} = message, node_id) do
    received_by = [node_id | (message.received_by || [])]
    message
    |> change_received_by(received_by)
    |> RescueMesh.Repo.update()
  end

  @doc """
  Obtém mensagens prioritárias.
  """
  def priority do
    RescueMesh.Repo.all(
      from m in RescueMesh.Messaging.Message,
      where: m.priority == "high"
    )
  end

  defp change_status(message, status) do
    %{message | status: status}
  end

  defp change_received_by(message, received_by) do
    %{message | received_by: received_by}
  end
end