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

    notes = Repo.all(Note)

    notes_data = AnkiViewer.notes_data!()

    new_notes_data = Enum.filter(notes_data, fn %{nid: nid} ->
      nid not in Enum.map(notes, &(&1.nid))
    end)

    new_notes_data
    |> Enum.with_index(1)
    |> Enum.each(fn {n, i} ->
      push(socket, "sync:msg", %{msg: "adding note #{i}/#{length(new_notes_data)}"})
      Note.insert!(n)
    end)

    old_notes_data = Enum.filter(notes, fn %{nid: nid} ->
      nid not in Enum.map(notes_data, &(&1.nid))
    end)

    old_notes_data
    |> Enum.with_index(1)
    |> Enum.each(fn {n, i} ->
      push(socket, "sync:msg", %{msg: "deleting note #{i}/#{length(old_notes_data)}"})
      Note.delete!(n)
    end)

    push(socket, "sync:msg", %{msg: "updated notes"})

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
