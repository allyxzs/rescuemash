defmodule RescueMesh.Repo.Migrations.AddDeliveryAttempts do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :attempts, :integer, null: false, default: 0
      add :last_attempt_at, :utc_datetime
    end

    create index(:messages, [:created_at])
  end
end
