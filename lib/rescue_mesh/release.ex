defmodule RescueMesh.Release do
  @moduledoc "Database migrations for the OTP release."
  def migrate do
    Application.load(:rescue_mesh)
    File.mkdir_p!(Path.dirname(Application.fetch_env!(:rescue_mesh, RescueMesh.Repo)[:database]))
    {:ok, _, _} = Ecto.Migrator.with_repo(RescueMesh.Repo, &Ecto.Migrator.run(&1, :up, all: true))
  end
end
