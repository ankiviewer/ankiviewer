defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("sync:database", _payload, socket) do
    #  hack to extend the socket timeout, see:
    # https://stackoverflow.com/questions/49331141/configure-channel-test-timeout-phoenix/49335536
    Process.send_after(self(), {:sync, :database}, 0)

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    push(socket, "one", %{})
    Process.sleep(500)
    push(socket, "two", %{})
    Process.sleep(500)
    push(socket, "three", %{})

    {:noreply, socket}
  end
end
