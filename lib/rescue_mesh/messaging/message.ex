defmodule RescueMesh.Messaging.Message do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "messages" do
    field :content, :string
    field :priority, :string, default: "normal"
    field :status, :string, default: "pending"
    field :created_at, :utc_datetime
    field :delivered_at, :utc_datetime, null: true
    field :received_by, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :priority, :status, :received_by])
    |> validate_required([:content])
    |> validate_length(:content, min: 1, max: 4096)
  end

  @doc """
  Obtém uma mensagem pelo ID.
  """
  def get_by_id(id) do
    RescueMesh.Repo.get(RescueMesh.Messaging.Message, id)
  end
end