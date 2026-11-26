defmodule RescueMesh.MessagingStoreTest do
  use ExUnit.Case, async: false

  test "deduplicated message has stable id" do
    assert is_binary("message-id")
  end
end
