defmodule RescueMesh.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RescueMesh.Repo,
      {Phoenix.PubSub, name: RescueMesh.PubSub},
      RescueMesh.NodeId,
      RescueMesh.Mesh.UDP,
      RescueMesh.Mesh.Discovery,
      RescueMesh.Mesh.Gossip,
      RescueMesh.Mesh.NeighborMonitor,
      RescueMesh.Messaging.Store,
      RescueMesh.Messaging.Queue,
      RescueMesh.Messaging.Sync,
      RescueMeshWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: RescueMesh.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
