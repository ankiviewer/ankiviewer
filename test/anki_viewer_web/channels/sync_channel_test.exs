defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false
  alias AnkiViewerWeb.SyncChannel

  describe "sync:database" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      {:ok, socket: socket}
    end

    test "socket pushes 3 messages", %{socket: _socket} do
      assert_push("updating collection", %{}, 1000)

      coll = Collection |> Repo.all()
      [%Collection{crt: crt, mod: mod, tags: tags}] = coll

      assert [
               1_480_996_800,
               1_514_655_628,
               ~w(duplicate leech marked sentence to-restructure verb verified-by-vanessa)
             ] == [crt, mod, tags]

      models = Model |> Repo.all()
      assert length(models) == 6
      [%Model{did: did, flds: flds, mid: mid, mod: mod, name: name} | _] = models

      assert [
               1_482_060_876,
               ["German", "English", "Hint"],
               1_482_842_770,
               1_514_653_350,
               "de_reverse"
             ] == [did, flds, mid, mod, name]

      decks = Deck |> Repo.all()
      assert length(decks) == 3
      [%Deck{did: did, mod: mod, name: name} | _] = decks
      assert [1, 1_482_840_611, "Default"] == [did, mod, name]
    end
  end
end
