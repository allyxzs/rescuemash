defmodule RescueMesh.MixProject do
  use Mix.Project

  def project do
    [
      app: :rescue_mesh,
      version: "1.0.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {RescueMesh.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 0.20.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.2"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, "~> 0.12.0"},
      {:libcluster, "~> 3.3"},
      {:swarm, "~> 3.4"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build", "ecto.create", "ecto.migrate"],
      "assets.setup": ["tailwind.install --if-missing"],
      "assets.build": ["tailwind default"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end