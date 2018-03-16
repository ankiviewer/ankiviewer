defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false

  alias AnkiViewerWeb.SyncChannel

  @tmp System.get_env("TMP_DIR") || "/tmp"

  describe "sync:database" do
    setup do
      System.cmd("sqlite3", ["#{@tmp}/anki_test.db", "'.read #{:code.priv_dir(:anki_viewer)}/anki_test_dump.sql'"])
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
