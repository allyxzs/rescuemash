defmodule RescueMesh.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :from_node, :content, :ttl, :priority, :status, :created_at, :attempts]}
  @primary_key {:id, :string, autogenerate: false}
  schema "messages" do
    field :from_node, :string
    field :content, :string
    field :ttl, :integer
    field :priority, :string, default: "normal"
    field :status, :string, default: "pending"
    field :delivered_to, :string, default: "[]"
    field :created_at, :utc_datetime
    field :attempts, :integer, default: 0
    field :last_attempt_at, :utc_datetime
    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [
      :id,
      :from_node,
      :content,
      :ttl,
      :priority,
      :status,
      :delivered_to,
      :created_at,
      :attempts,
      :last_attempt_at
    ])
    |> validate_required([:id, :from_node, :content, :ttl, :created_at])
    |> validate_format(:id, ~r/\A[0-9a-f-]{36,64}\z/)
    |> validate_format(:from_node, ~r/\A[0-9a-f-]{36}\z/)
    |> validate_number(:ttl, greater_than_or_equal_to: 1, less_than_or_equal_to: 8)
    |> validate_number(:attempts, greater_than_or_equal_to: 0)
    |> validate_inclusion(:priority, ["normal", "high", "critical"])
    |> validate_inclusion(:status, ["pending", "delivered", "failed", "received"])
    |> validate_length(:content, min: 1, max: 2_000)
    |> unique_constraint(:id)
  end

  def packet(message) do
    %{
      "type" => "message",
      "id" => message.id,
      "from" => message.from_node,
      "content" => message.content,
      "priority" => message.priority,
      "ttl" => message.ttl,
      "ts" => DateTime.to_unix(message.created_at)
    }
  end
end
