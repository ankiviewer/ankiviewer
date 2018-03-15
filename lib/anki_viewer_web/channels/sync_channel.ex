defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("sync:database", _payload, socket) do
    Process.sleep(500)
    {:ok, socket}
  end

  def join("sync:rule", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("ping", payload, socket) do
    IO.puts "hi"
    {:reply, {:ok, payload}, socket}
  end
end
