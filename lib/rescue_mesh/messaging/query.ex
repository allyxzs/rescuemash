defmodule RescueMesh.Messaging.Query do
  import Ecto.Query, warn: false
  alias RescueMesh.Messaging.Message

  def pending do
    from m in Message,
      where: m.status == "pending",
      order_by: [desc: m.priority, asc: m.created_at]
  end

  def by_node(node_id) do
    from m in Message,
      where: m.from_node == ^node_id
  end

  def delivered_to(node_id) do
    from m in Message,
      where: ^node_id in m.delivered_to
  end
end