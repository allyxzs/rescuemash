defmodule RescueMesh.DataCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RescueMesh.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(RescueMesh.Repo, {:shared, self()})
    :sys.replace_state(RescueMesh.Mesh.Discovery, fn _ -> %{} end)
    :sys.replace_state(RescueMesh.RateLimiter, fn _ -> %{} end)
    :ok
  end

  def packet(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => Ecto.UUID.generate(),
        "from" => Ecto.UUID.generate(),
        "content" => "Mensagem de teste",
        "priority" => "normal",
        "ttl" => 8,
        "ts" => System.system_time(:second)
      },
      attrs
    )
  end

  def neighbor(port \\ 45678) do
    id = Ecto.UUID.generate()

    RescueMesh.Mesh.Discovery.observe({127, 0, 0, 1}, %{
      "type" => "hello",
      "node_id" => id,
      "port" => port
    })

    RescueMesh.Mesh.Discovery.get_neighbors()
    id
  end
end
