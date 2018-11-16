defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("sync:database", _payload, socket) do
    send(self(), {:sync, :database})

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    push(socket, "sync:msg", %{msg: "starting sync", percentage: 0})

    collection_data = AnkiViewer.collection_data!()

    collection_data
    |> Map.take(~w(crt mod tags)a)
    |> Collection.insert_or_update!()

    collection_data |> Map.fetch!(:models) |> Model.insert_or_update!()
    collection_data |> Map.fetch!(:decks) |> Deck.insert_or_update!()

    push(socket, "sync:msg", %{msg: "updated collection", percentage: 10})

    new_cards_data = AnkiViewer.cards_data!()

    current_cards_data = Repo.all(Card)

    push(socket, "sync:msg", %{msg: "calculating cards to add", percentage: 20})

    cards_data_to_add =
      Enum.filter(new_cards_data, fn %{cid: cid} ->
        cid not in Enum.map(current_cards_data, &Map.get(&1, :cid))
      end)

    push(socket, "sync:msg", %{msg: "calculating cards to delete", percentage: 30})

    cards_data_to_delete =
      Enum.filter(current_cards_data, fn %{cid: cid} ->
        cid not in Enum.map(new_cards_data, &Map.get(&1, :cid))
      end)

    push(socket, "sync:msg", %{msg: "calculating cards to update", percentage: 40})

    cards_data_to_update =
      Enum.filter(new_cards_data, fn %{cid: new_cid, nmod: new_nmod, cmod: new_cmod} ->
        new_cid in Enum.map(current_cards_data, &Map.get(&1, :cid)) and
          current_cards_data
          |> Enum.find(fn %{cid: current_cid} ->
            current_cid == new_cid
          end)
          |> Map.take(~w(cmod nmod)a) != %{cmod: new_cmod, nmod: new_nmod}
      end)

    cards_data_to_add
    |> Enum.with_index(1)
    |> Enum.each(fn {card, i} ->
      push(socket, "sync:msg", %{
        msg: "adding card #{i}/#{length(cards_data_to_add)}",
        percentage: 50 + round(i / length(cards_data_to_add) * 10)
      })

      Card.insert!(card)
    end)

    cards_data_to_delete
    |> Enum.with_index(1)
    |> Enum.each(fn {card, i} ->
      push(socket, "sync:msg", %{
        msg: "deleting card #{i}/#{length(cards_data_to_delete)}",
        percentage: 60 + round(i / length(cards_data_to_delete) * 10)
      })

      Repo.delete!(card)
    end)

    cards_data_to_update
    |> Enum.with_index(1)
    |> Enum.each(fn {card, i} ->
      push(socket, "sync:msg", %{
        msg: "updating card #{i}/#{length(cards_data_to_update)}",
        percentage: 70 + round(i / length(cards_data_to_update) * 10)
      })

      card
      |> Map.take(~w(cid nid cmod nmod flds sfld)a)
      |> Card.update!()
    end)

    push(socket, "sync:msg", %{msg: "updated cards", percentage: 100})

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
