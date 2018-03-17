defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("sync:database", _payload, socket) do
    Process.send_after(self(), {:sync, :database}, 100)

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    push(socket, "one", %{})
    Process.sleep(3000)
    push(socket, "two", %{})
    Process.sleep(3000)
    push(socket, "three", %{})

    {:noreply, socket}
  end
end
