defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("sync:database", _payload, socket) do
    send(self(), {:sync, :database})

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
