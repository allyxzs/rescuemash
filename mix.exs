defmodule RescueMesh.MixProject do
  use Mix.Project

  def project do
    [
      app: :rescue_mesh,
      version: "3.0.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application,
    do: [mod: {RescueMesh.Application, []}, extra_applications: [:logger, :crypto, :ssl]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.21"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.2.15"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.5"},
      {:ecto_sql, "~> 3.14.0"},
      {:ecto_sqlite3, "~> 0.26.0"},
      {:phoenix_ecto, "~> 4.6"},
      {:lazy_html, "~> 0.1", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.build", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.build": ["run --no-start scripts/build_assets.exs"]
    ]
  end
end
