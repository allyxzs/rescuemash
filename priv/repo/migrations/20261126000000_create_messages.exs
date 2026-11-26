defmodule RescueMesh.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :string, primary_key: true
      add :from_node, :string, null: false
      add :content, :text, null: false
      add :ttl, :integer, null: false
      add :priority, :string, null: false, default: "normal"
      add :status, :string, null: false, default: "pending"
      add :delivered_to, :text, null: false, default: "[]"
      add :created_at, :utc_datetime, null: false
      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:status, :priority])
    create index(:messages, [:from_node])
  end
end
