defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false

  alias AnkiViewerWeb.SyncChannel

  describe "sync:database" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      {:ok, socket: socket}
    end

    test "socket pushes 3 messages", %{socket: _socket} do
      assert_push("one", %{})
      assert_push("two", %{})
      assert_push("three", %{})
    end
  end
end
