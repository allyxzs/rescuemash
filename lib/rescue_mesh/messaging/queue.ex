defmodule RescueMesh.Messaging.Queue do
  @moduledoc """
  Fila de mensagens por prioridade com retry automático.
  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{retries: %{}}}
  end

  def enqueue(msg) do
    GenServer.cast(__MODULE__, {:enqueue, msg})
  end

  @impl true
  def handle_cast({:enqueue, msg}, state) do
    # Lógica de fila por prioridade
    {:noreply, state}
  end
end