defmodule RescueMesh.Application do
  use Application
  @impl true
  def start(_type, _args) do
    File.mkdir_p!(Path.dirname(Application.fetch_env!(:rescue_mesh, RescueMesh.Repo)[:database]))

    children = [
      RescueMesh.Repo,
      {Phoenix.PubSub, name: RescueMesh.PubSub},
      RescueMesh.NodeId,
      RescueMesh.RateLimiter,
      RescueMesh.Mesh.Discovery,
      RescueMesh.Mesh.Gossip,
      RescueMesh.Mesh.UDP,
      RescueMesh.Messaging.Queue,
      RescueMeshWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RescueMesh.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    RescueMeshWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
