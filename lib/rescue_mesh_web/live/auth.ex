defmodule RescueMeshWeb.Live.Auth do
  import Phoenix.LiveView

  def on_mount(:default, _params, session, socket) do
    if RescueMesh.Security.authorized_hash?(session["auth_hash"]) do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end
end
