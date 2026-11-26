defmodule RescueMesh.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      RescueMesh.Repo,
      RescueMesh.Mesh.Node,
      RescueMesh.Mesh.Discovery,
      RescueMesh.Mesh.Gossip,
      RescueMesh.Messaging.Store,
      RescueMesh.Endpoint
    ]

    opts = [strategy: :one_for_one, name: RescueMesh.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
