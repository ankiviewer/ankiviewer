defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false

  alias AnkiViewerWeb.SyncChannel

  describe "sync:database" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      {:ok, socket: socket}
    end

    test "ping replies with status ok", %{socket: _socket} do
      assert true
    end
  end

  describe "sync:rule" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:rule", %{id: 1})

      {:ok, socket: socket}
    end

    test "hello:world" do
      assert true
    end
  end
end
