defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("sync:database", _payload, socket) do
    send(self(), {:sync, :database})

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    push(socket, "sync:msg", %{msg: "starting sync"})

    collection_data = AnkiViewer.collection_data!()

    collection_data
    |> Map.take(~w(crt mod tags)a)
    |> Collection.insert_or_update!()

    collection_data |> Map.fetch!(:models) |> Model.insert_or_update!()
    collection_data |> Map.fetch!(:decks) |> Deck.insert_or_update!()

    push(socket, "sync:msg", %{msg: "updated collection"})

    Repo.delete_all(Note)

    notes_data = AnkiViewer.notes_data!()

    for {n, i} <- Enum.with_index(notes_data) do
      push(socket, "sync:msg", %{msg: "updating note #{i}/#{length(notes_data)}"})
      Note.insert!(n)
    end

    push(socket, "sync:msg", %{msg: "updated notes"})

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
