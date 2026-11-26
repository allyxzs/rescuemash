defmodule RescueMeshWeb.SecurityTest do
  use ExUnit.Case, async: true

  test "production secrets are environment-driven" do
    refute File.read!("config/runtime.exs") =~ "SECRET_KEY_BASE=\""
  end
end
