defmodule RescueMesh.Messaging.Queue do
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  @impl true
  def init(_) do
    if Application.get_env(:rescue_mesh, :queue_enabled), do: schedule()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:tick, state) do
    RescueMesh.Mesh.Gossip.retry_pending()
    schedule()
    {:noreply, state}
  end

  defp schedule,
    do:
      Process.send_after(self(), :tick, Application.fetch_env!(:rescue_mesh, :queue_interval_ms))
end
