defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false

  describe "sync:database - from empty" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(AnkiSocket), SyncChannel, "ankiviewer:join")

      push(socket, "sync:database", %{})

      {:ok, socket: socket}
    end

    test "collection is updated as expected", %{socket: _socket} do
      assert_push("sync:msg", %{msg: "updated collection"})
      assert_push("sync:done", %{})

      coll = Collection |> Repo.all()
      [%Collection{crt: crt, mod: mod, tags: tags}] = coll

      assert [
               1_480_996_800,
               1_514_655_628_599,
               ~w(duplicate leech marked sentence to-restructure verb verified-by-vanessa)
             ] == [crt, mod, tags]
    end

    test "model is updated as expected", %{socket: _socket} do
      assert_push("sync:done", %{})
      models = Model |> Repo.all()
      assert length(models) == 6
      [%Model{did: did, flds: flds, mid: mid, mod: mod, name: name} | _] = models

      assert [
               1_482_060_876_072,
               ["German", "English", "Hint"],
               1_482_842_770_192,
               1_514_653_350,
               "de_reverse"
             ] == [did, flds, mid, mod, name]
    end

    test "deck is updated as expected", %{socket: _socket} do
      assert_push("sync:done", %{})
      decks = Deck |> Repo.all()
      assert length(decks) == 3
      [%Deck{did: did, mod: mod, name: name} | _] = decks
      assert [1, 1_482_840_611, "Default"] == [did, mod, name]
    end

    test "cards are added as expected", %{socket: _socket} do
      refute_push("sync:msg", %{msg: "adding card 0/10"})
      assert_push("sync:msg", %{msg: "adding card 1/10"})
      assert_push("sync:msg", %{msg: "adding card 2/10"})
      assert_push("sync:msg", %{msg: "adding card 3/10"})
      assert_push("sync:msg", %{msg: "adding card 4/10"})
      assert_push("sync:msg", %{msg: "adding card 5/10"})
      assert_push("sync:msg", %{msg: "adding card 6/10"})
      assert_push("sync:msg", %{msg: "adding card 7/10"})
      assert_push("sync:msg", %{msg: "adding card 8/10"})
      assert_push("sync:msg", %{msg: "adding card 9/10"})
      assert_push("sync:msg", %{msg: "adding card 10/10"})
      refute_push("sync:msg", %{msg: "adding card 11/10"})
      assert_push("sync:msg", %{msg: "updated cards"})
      assert_push("sync:done", %{})

      cards = Repo.all(Card)

      assert length(cards) == 10
    end
  end

  describe "sync:database - with initial data" do
    setup do
      load_collection!()

      {:ok, _, socket} = subscribe_and_join(socket(AnkiSocket), SyncChannel, "ankiviewer:join")

      {:ok, socket: socket}
    end

    test "cards don't rerun when there is nothing to update", %{socket: socket} do
      push(socket, "sync:database", %{})

      refute_push("sync:msg", %{msg: "adding card 1/10"})
    end

    test "cards add 1", %{socket: socket} do
      Repo.all(Card) |> List.first() |> Repo.delete!()

      push(socket, "sync:database", %{})

      refute_push("sync:msg", %{msg: "adding card 0/1"})
      assert_push("sync:msg", %{msg: "adding card 1/1"})

      assert Card |> Repo.all() |> length() == 10
    end

    test "cards delete 1", %{socket: socket} do
      %{
        cid: 123,
        cmod: 123,
        did: 123,
        due: 123,
        flds: "onetwo",
        lapses: 123,
        mid: 123,
        nid: 123,
        nmod: 123,
        ord: 123,
        queue: 123,
        reps: 123,
        sfld: "two",
        tags: [],
        type: 123
      }
      |> Card.insert!()

      push(socket, "sync:database", %{})

      refute_push("sync:msg", %{msg: "deleting card 0/1"})
      assert_push("sync:msg", %{msg: "deleting card 1/1"})

      assert Card |> Repo.all() |> length() == 10
    end

    test "cards update 1", %{socket: socket} do
      cid = 1_506_600_429_296

      original_card = Repo.get(Card, cid)

      now = DateTime.utc_now() |> DateTime.to_unix()

      new_card = %{
        cmod: now,
        nmod: now,
        flds: "Unnützuseful",
        sfld: "useful"
      }

      new_card
      |> Map.merge(%{cid: cid})
      |> Card.update!()

      push(socket, "sync:database", %{})

      refute_push("sync:msg", %{msg: "updating card 0/1"})
      assert_push("sync:msg", %{msg: "updating card 1/1"})

      assert Card |> Repo.all() |> length() == 10

      assert Card |> Repo.get(cid) |> Map.take(~w(cmod nmod flds sfld)a) ==
               Map.take(original_card, ~w(cmod nmod flds sfld)a)
    end
  end

  describe "rule:run" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(AnkiSocket), SyncChannel, "ankiviewer:join")

      {:ok, socket: socket}
    end

    test "with no failing cards", %{socket: socket} do
      %{rid: rid} =
        %{
          name: "no blank fields",
          code: ~s(card.sfld != ""),
          tests: "[]"
        }
        |> Rule.insert!()

      load_collection!()
      dids = Deck |> Repo.all() |> Enum.map(&Map.get(&1, :did))

      assert Repo.all(CardRule) == []

      push(socket, "rule:run", %{"rid" => rid, "dids" => dids})

      assert_push("rule:msg", %{msg: "starting run"})

      assert_push("rule:done", %{})

      cards = Repo.all(CardRule)

      assert length(cards) == 10
      assert Enum.all?(cards, &(not &1.fails))
    end

    test "with failing cards", %{socket: socket} do
      %{rid: rid} =
        %{
          name: "only blank fields",
          code: ~s(card.sfld == ""),
          tests: "[]"
        }
        |> Rule.insert!()

      load_collection!()
      dids = Deck |> Repo.all() |> Enum.map(&Map.get(&1, :did))

      assert Repo.all(CardRule) == []

      push(socket, "rule:run", %{"rid" => rid, "dids" => dids})

      assert_push("rule:msg", %{msg: "starting run"})

      assert_push("rule:done", %{})

      cards = Repo.all(CardRule)

      assert length(cards) == 10
      assert Enum.all?(cards, & &1.fails)
    end

    test "ensure no duplicates", %{socket: socket} do
      %{rid: rid} =
        %{
          name: "no duplicate sfld",
          code:
            "Enum.any?(cards, fn %{nid: nid, sfld: sfld} -> sfld == card.sfld and card.nid != nid end)",
          tests: "[]"
        }
        |> Rule.insert!()

      load_collection!()
      dids = Deck |> Repo.all() |> Enum.map(&Map.get(&1, :did))

      generous_card = Card |> Repo.all() |> Enum.find(fn %{sfld: sfld} -> sfld == "generous" end)

      Card.insert!(%{generous_card | cid: generous_card.cid + 1, nid: generous_card.nid + 1})

      push(socket, "rule:run", %{"rid" => rid, "dids" => dids})

      assert_push("rule:msg", %{msg: "starting run"})

      assert_push("rule:done", %{})

      card_rules = Repo.all(CardRule)

      assert length(card_rules) == 11
      assert length(Enum.filter(card_rules, &Map.get(&1, :fails))) == 8
      assert length(Enum.filter(card_rules, &(not Map.get(&1, :fails)))) == 3
    end
  end
end
