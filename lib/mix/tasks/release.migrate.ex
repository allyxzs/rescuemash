defmodule RescueMesh.ReleaseTasks do
  @moduledoc """
  Release tasks for RescueMesh.
  """
  def migrate do
    {:ok, _} = Application.ensure_all_started(:ecto_sql)
    {:ok, _} = Application.ensure_all_started(:ecto_sqlite3)

    path = Application.app_dir(:rescue_mesh, "priv/repo/migrations")

    Ecto.Migrator.run(
      RescueMesh.Repo,
      path,
      :up,
      all: true
    )
  end
end