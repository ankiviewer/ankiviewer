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
    {_x, 0} = System.cmd("sqlite3", [@anki_db_path, "select * from col"])
    {_y, 0} = System.cmd("sqlite3", [@anki_db_path, "select c.id as cid, c.mod as cmod, c.did as did, c.due as due, n.flds as flds, c.lapses as lapses, n.mid as mid, n.id as nid, n.mod as nmod, c.ord as ord, c.queue as queue, c.reps as reps, n.sfld as sfld, n.tags as tags, c.type as type from notes as n inner join cards as c on n.id = c.nid"])
    # IO.inspect x
    # IO.inspect y
    push(socket, "one", %{})
    Process.sleep(100)
    push(socket, "two", %{})
    Process.sleep(100)
    push(socket, "three", %{})

    {:noreply, socket}
  end
end
