defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  @anki_db_path Application.get_env(:anki_viewer, :anki_db_path)

  def join("sync:database", _payload, socket) do
    #  hack to extend the socket timeout, see:
    # https://stackoverflow.com/questions/49331141/configure-channel-test-timeout-phoenix/49335536
    Process.send_after(self(), {:sync, :database}, 0)

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    {x, 0} = System.cmd("sqlite3", [@anki_db_path, "select * from col"])
    IO.inspect x
    push(socket, "one", %{})
    Process.sleep(100)
    push(socket, "two", %{})
    Process.sleep(100)
    push(socket, "three", %{})

    {:noreply, socket}
  end
end
