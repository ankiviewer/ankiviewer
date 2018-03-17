defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false

  alias AnkiViewerWeb.SyncChannel

  describe "sync:database" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      {:ok, socket: socket}
    end

    test "socket pushes 3 messages", %{socket: _socket} do
      assert_push("one", %{}, 10000)
      assert_push("two", %{}, 10000)
      assert_push("three", %{}, 10000)
    end
  end
end
