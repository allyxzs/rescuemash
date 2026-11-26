defmodule RescueMesh.RateLimiter do
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def allow?(key, limit), do: GenServer.call(__MODULE__, {:allow, key, limit})
  @impl true
  def init(_) do
    Process.send_after(self(), :cleanup, 60_000)
    {:ok, %{}}
  end

  @impl true
  def handle_call({:allow, key, limit}, _from, state) do
    now = System.monotonic_time(:second)
    {count, expires} = Map.get(state, key, {0, now + 60})
    {count, expires} = if now >= expires, do: {0, now + 60}, else: {count, expires}

    cond do
      count >= limit -> {:reply, false, state}
      map_size(state) >= 10_000 and not Map.has_key?(state, key) -> {:reply, false, state}
      true -> {:reply, true, Map.put(state, key, {count + 1, expires})}
    end
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.monotonic_time(:second)
    Process.send_after(self(), :cleanup, 60_000)
    {:noreply, Map.reject(state, fn {_key, {_count, expires}} -> now >= expires end)}
  end
end
