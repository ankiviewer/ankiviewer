defmodule AnkiViewerWeb.SyncChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false

  import Ecto.Query

  alias AnkiViewerWeb.SyncChannel

  describe "sync:database" do
    setup do
      {:ok, _, socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      {:ok, socket: socket}
    end

    test "socket pushes 3 messages", %{socket: _socket} do
      assert_push("sync:msg", %{msg: "updated collection"})

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

      assert_push("sync:msg", %{msg: "updated notes"})
      assert_push("done", %{})

      notes = Note |> Repo.all()

      assert length(notes) == 10
    end

    test "joining twice updates initial notes", %{socket: _socket} do
      assert_push("sync:msg", %{msg: "updated collection"})

      assert_push("sync:msg", %{msg: "adding note 1/10"})
      assert_push("sync:msg", %{msg: "adding note 2/10"})
      assert_push("sync:msg", %{msg: "adding note 3/10"})
      assert_push("sync:msg", %{msg: "adding note 4/10"})
      assert_push("sync:msg", %{msg: "adding note 5/10"})
      assert_push("sync:msg", %{msg: "adding note 6/10"})
      assert_push("sync:msg", %{msg: "adding note 7/10"})
      assert_push("sync:msg", %{msg: "adding note 8/10"})
      assert_push("sync:msg", %{msg: "adding note 9/10"})
      assert_push("sync:msg", %{msg: "adding note 10/10"})

      assert_push("sync:msg", %{msg: "updated notes"})
      assert_push("done", %{})

      assert Repo.one(Collection)
      assert Model |> Repo.all() |> length == 6
      assert Deck |> Repo.all() |> length == 3
      notes = Note |> Repo.all()
      assert notes |> length == 10

      # Remove 2 notes
      Note
      |> where([n], n.nid in ^(notes |> Enum.take(2) |> Enum.map(&(&1.nid))))
      |> Repo.delete_all

      # Add a new note (which will subsequently be deleted)
      # %Note{
      #   cid: 0,
      #   cmod: 0,
      #   did: 0,
      #   due: 0,
      #   flds: "asdf",
      #   lapses: 1,
      #   mid: 123,
      #   nid: 456543,
      #   nmod: 5432,
      #   ord: 0,
      #   queue: 0,
      #   reps: 0,
      #   sfld: "asdfasdf",
      #   tags: [],
      #   type: 1
      # }
      # |> Note.insert!()

      # {:ok, _, _socket} = subscribe_and_join(socket(), SyncChannel, "sync:database")

      # assert_push("sync:msg", %{msg: "updated collection"})

      # assert_push("sync:msg", %{msg: "adding note 1/2"})
      # assert_push("sync:msg", %{msg: "adding note 2/2"})

      # assert_push("sync:msg", %{msg: "updated notes"})
      # assert_push("done", %{})

      # assert Repo.one(Collection)
      # assert Model |> Repo.all() |> length == 6
      # assert Deck |> Repo.all() |> length == 3
      # assert Note |> Repo.all() |> length == 10
    end
  end
end
