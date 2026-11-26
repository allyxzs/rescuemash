[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "priv/repo/**/*.exs",
    "mix.exs",
    ".formatter.exs",
    "{config,lib,test,scripts}/**/*.{ex,exs,heex}"
  ]
]
