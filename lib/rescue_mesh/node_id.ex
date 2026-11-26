defmodule RescueMesh.NodeId do
  @moduledoc """
  Gera e persiste um identificador único e estável para este nó.
  O ID é armazenado em disco para que sobreviva a reinicializações.
  """
  use GenServer

  @node_id_file Application.compile_env!(:rescue_mesh, :node_id_path)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  @impl true
  def init(_) do
    node_id = load_or_generate()
    {:ok, %{node_id: node_id}}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state.node_id, state}
  end

  defp load_or_generate do
    case File.read(@node_id_file) do
      {:ok, id} when byte_size(id) == 36 ->
        String.trim(id)

      _ ->
        id = generate_uuid()
        File.mkdir_p!(Path.dirname(@node_id_file))
        File.write!(@node_id_file, id)
        id
    end
  end

  defp generate_uuid do
    :crypto.strong_rand_bytes(16)
    |> :binary.bin_to_list()
    |> Enum.map(&Integer.to_string(&1, 16))
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join()
    |> String.downcase()
    |> String.replace(~r/(.{8})(.{4})(.{4})(.{4})(.{12})/, "\\1-\\2-\\3-\\4-\\5")
  end
end
