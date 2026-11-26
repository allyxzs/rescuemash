defmodule RescueMesh.NodeId do
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def get, do: GenServer.call(__MODULE__, :get)
  @impl true
  def init(_) do
    path = Application.fetch_env!(:rescue_mesh, :node_id_path)

    id =
      case File.read(path) do
        {:ok, value} ->
          case Ecto.UUID.cast(String.trim(value)) do
            {:ok, uuid} -> uuid
            :error -> raise "Invalid node ID; restore a valid backup: #{path}"
          end

        {:error, :enoent} ->
          uuid = Ecto.UUID.generate()
          File.mkdir_p!(Path.dirname(path))
          File.write!(path <> ".tmp", uuid)
          File.rename!(path <> ".tmp", path)
          uuid

        {:error, reason} ->
          raise "Cannot read node ID: #{inspect(reason)}"
      end

    {:ok, id}
  end

  @impl true
  def handle_call(:get, _from, id), do: {:reply, id, id}
end
