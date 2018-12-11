defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  def join("ankiviewer:join", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("sync:database", _params, socket) do
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

      CardRule
      |> where([cr], cr.cid == ^card.cid)
      |> Repo.delete_all()
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

      CardRule
      |> where([cr], cr.cid == ^card.cid)
      |> Repo.delete_all()
    end)

    push(socket, "sync:msg", %{msg: "updated cards", percentage: 100})

    push(socket, "sync:done", %{})

    {:noreply, socket}
  end

  def handle_in("rule:run", %{"rid" => rid}, socket) do
    push(socket, "rule:msg", %{msg: "starting run", percentage: 0, seconds: 0})

    cards = Repo.all(Card)
    rule = Repo.get(Rule, rid)

    already_run_cids =
      Card
      |> join(:inner, [c], cr in CardRule, on: c.cid == cr.cid)
      |> where([c, cr], cr.rid == ^rid)
      |> select([c, cr], c.cid)
      |> Repo.all()

    cards_length = length(cards)

    pid =
      spawn(fn ->
        cards
        |> Enum.with_index()
        |> Enum.filter(fn {card, _i} ->
          card.cid not in already_run_cids
        end)
        |> Enum.reduce(%{timestamp: DateTime.utc_now(), diff: 0}, fn {card, i},
                                                                     %{
                                                                       timestamp: timestamp,
                                                                       diff: diff
                                                                     } ->
          now = DateTime.utc_now()

          new_diff =
            Integer.floor_div((i + 1) * diff + DateTime.diff(now, timestamp, :microsecond), i + 2)

          push(socket, "rule:msg", %{
            msg: "running rule #{i}/#{length(cards)}",
            percentage: round(i / length(cards) * 100),
            seconds: Integer.floor_div((cards_length - i) * new_diff, 1_000_000)
          })

          %CardRule{cid: card.cid, rid: rid}
          |> Map.merge(
            case CardRule.run(cards, card, rule) do
              :ok ->
                %{fails: false}

              {:error, ""} ->
                %{fails: true}

                # TODO: pass solution along
                # {:error, solution} ->
                #   %{fails: true, solution: solution}
            end
          )
          |> CardRule.insert!()

          %{timestamp: now, diff: new_diff}
        end)

        push(socket, "rule:done", %{})
      end)

    socket = assign(socket, :pid, pid)

    {:noreply, socket}
  end

  def handle_in("rule:stop", _params, socket) do
    pid = socket.assigns[:pid]

    if pid && Process.alive?(pid) do
      Process.exit(pid, :kill)

      assign(socket, :pid, nil)
    end

    {:noreply, socket}
  end
end
