defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase

  alias AnkiViewerWeb.SyncChannel

  describe "sync:database" do
    setup do
      {:ok, _, socket} =
        subscribe_and_join socket(), SyncChannel, "sync:database"

      {:ok, socket: socket}
    end

    test "ping replies with status ok", %{socket: socket} do
      ref = push socket, "ping", %{"hello" => "there"}
      assert_reply ref, :ok, %{"hello" => "there"}
    end
  end

  describe "sync:rule" do
    setup do
      {:ok, _, socket} =
        subscribe_and_join(socket(), SyncChannel, "sync:rule", %{id: 1})

      {:ok, socket: socket}
    end

    test "hello:world" do
      assert true
    end
  end
end
