defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false
  alias AnkiViewerWeb.SyncChannel

  describe "sync:database - from empty" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      {:ok, socket: socket}
    end

    test "collection is updated as expected", %{socket: _socket} do
      assert_push("sync:msg", %{msg: "updated collection"})
      assert_push("done", %{})

      coll = Collection |> Repo.all()
      [%Collection{crt: crt, mod: mod, tags: tags}] = coll

      assert [
               1_480_996_800,
               1_514_655_628_599,
               ~w(duplicate leech marked sentence to-restructure verb verified-by-vanessa)
             ] == [crt, mod, tags]
    end

    test "model is updated as expected", %{socket: _socket} do
      assert_push("done", %{})
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
      assert_push("done", %{})
      decks = Deck |> Repo.all()
      assert length(decks) == 3
      [%Deck{did: did, mod: mod, name: name} | _] = decks
      assert [1, 1_482_840_611, "Default"] == [did, mod, name]
    end

    test "cards are updated as expected", %{socket: _socket} do
      refute_push("sync:msg", %{msg: "updating card 0/10"})
      assert_push("sync:msg", %{msg: "updating card 1/10"})
      assert_push("sync:msg", %{msg: "updating card 2/10"})
      assert_push("sync:msg", %{msg: "updating card 3/10"})
      assert_push("sync:msg", %{msg: "updating card 4/10"})
      assert_push("sync:msg", %{msg: "updating card 5/10"})
      assert_push("sync:msg", %{msg: "updating card 6/10"})
      assert_push("sync:msg", %{msg: "updating card 7/10"})
      assert_push("sync:msg", %{msg: "updating card 8/10"})
      assert_push("sync:msg", %{msg: "updating card 9/10"})
      assert_push("sync:msg", %{msg: "updating card 10/10"})
      refute_push("sync:msg", %{msg: "updating card 11/10"})
      assert_push("sync:msg", %{msg: "updated cards"})
      assert_push("done", %{})

      cards = Repo.all(Card)

      assert length(cards) == 10
    end
  end

  describe "sync:database - with initial data" do
    setup do
      load_collection!()

      :ok
    end

    test "cards don't rerun when there is nothing to update" do
      {:ok, _, _socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      refute_push("sync:msg", %{msg: "updating card 1/10"})
    end

    # test "cards run once when there is 1 card to add" do
    #   Repo.all(Card) |> List.first

    #   {:ok, _, _socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

    #   assert_push("sync:msg", %{msg: "updating card 1/1"})
    # end
  end
end
