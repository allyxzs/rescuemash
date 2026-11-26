defmodule RescueMesh.Messaging.Migration20240101 do
  use Ecto.Migration

  def change do
    create table(:messages) do
      uuid_extension(:id)
      field(:content, :string, null: false)
      field(:priority, :string, default: "normal")
      field(:status, :string, default: "pending")
      field(:created_at, :utc_datetime, null: false)
      field(:delivered_at, :utc_datetime)
      field(:received_by, {:array, :string}, default: [])
      timestamps()
    end
  end
end