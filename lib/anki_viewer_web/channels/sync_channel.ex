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

    new_cards_data = AnkiViewer.cards_data!()

    current_cards_data = Repo.all(Card)

    filtered_new_cards_data =
      Enum.filter(new_cards_data, fn card ->
        card.nid not in Enum.map(current_cards_data, &Map.get(&1, :nid))
      end)

    filtered_new_cards_data
    |> Enum.with_index(1)
    |> Enum.each(fn {n, i} ->
      push(socket, "sync:msg", %{msg: "updating card #{i}/#{length(filtered_new_cards_data)}"})
      Card.insert!(n)
    end)

    push(socket, "sync:msg", %{msg: "updated cards"})

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
