File.mkdir_p!("priv/static/assets")

for {package, filename} <- [
      {"phoenix", "phoenix.js"},
      {"phoenix_live_view", "phoenix_live_view.js"}
    ] do
  File.cp!(
    Path.join(["deps", package, "priv/static", filename]),
    Path.join("priv/static/assets", filename)
  )
end

IO.puts("Local LiveView assets ready; no Node/npm/CDN required.")
