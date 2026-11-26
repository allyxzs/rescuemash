defmodule RescueMesh.Repo do
  use Ecto.Repo,
    otp_app: :rescue_mesh,
    adapter: Ecto.Adapters.SQLite3
end
