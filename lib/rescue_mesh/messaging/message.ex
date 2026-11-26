defmodule RescueMesh.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "messages" do
    field :from_node, :string
    field :content, :string
    field :ttl, :integer
    field :priority, :string, default: "normal"
    field :status, :string, default: "pending"
    field :delivered_to, :string, default: "[]"
    field :created_at, :utc_datetime
    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:id, :from_node, :content, :ttl, :priority, :status, :delivered_to, :created_at])
    |> validate_required([:id, :from_node, :content, :ttl, :created_at])
    |> validate_inclusion(:priority, ["normal", "high", "critical"])
    |> validate_inclusion(:status, ["pending", "delivered", "failed"])
    |> validate_length(:content, max: 65_536)
    |> unique_constraint(:id)
  end
end
