defmodule AnkiViewer.CollectionTest do
  use AnkiViewer.DataCase, async: false

  test "insert_or_update a new collection" do
    attrs = %{crt: 123, mod: 123, tags: []}

    Collection.insert_or_update!(attrs)

    [%Collection{crt: crt, mod: mod, tags: tags}] = Repo.all(Collection)
    assert [crt, mod, tags] == [123, 123, []]
  end

  test "insert_or_update a pre existing collection" do
    attrs1 = %{crt: 123, mod: 123, tags: []}
    attrs2 = %{crt: 456, mod: 456, tags: ["one"]}

    %Collection{}
    |> Collection.changeset(attrs1)
    |> Repo.insert!()

    [%Collection{crt: crt, mod: mod, tags: tags}] = Repo.all(Collection)
    assert [crt, mod, tags] == [123, 123, []]

    Collection.insert_or_update!(attrs2)

    [%Collection{crt: crt, mod: mod, tags: tags}] = Repo.all(Collection)
    assert [crt, mod, tags] == [456, 456, ["one"]]

    %Collection{crt: 789, mod: 789, tags: ["one", "two"]}
    |> Collection.insert_or_update!()

    [%Collection{crt: 789, mod: 789, tags: ["one", "two"]}] = Repo.all(Collection)
  end

  test "insert_or_update a single deck" do
    attrs1 = %{did: 123, mod: 123, name: "name1"}
    attrs2 = %{did: 456, mod: 456, name: "name2"}

    %Deck{}
    |> Deck.changeset(attrs1)
    |> Repo.insert!()

    [%Deck{did: 123, mod: 123, name: "name1"}] = Repo.all(Deck)

    Deck.insert_or_update!(attrs2)

    [%Deck{did: 456, mod: 456, name: "name2"}] = Repo.all(Deck)

    %Deck{did: 789, mod: 789, name: "name3"}
    |> Deck.insert_or_update!()

    [%Deck{did: 789, mod: 789, name: "name3"}] = Repo.all(Deck)
  end

  test "insert_or_update multiple decks" do
    attrs1 = [
      %{did: 1, mod: 1, name: "name1"},
      %{did: 2, mod: 2, name: "name2"}
    ]

    attrs2 = [
      %{did: 3, mod: 3, name: "name3"},
      %{did: 4, mod: 4, name: "name4"}
    ]

    for a <- attrs1 do
      %Deck{} |> Deck.changeset(a) |> Repo.insert!()
    end

    [
      %Deck{did: 1, mod: 1, name: "name1"},
      %Deck{did: 2, mod: 2, name: "name2"}
    ] = Repo.all(Deck)

    Deck.insert_or_update!(attrs2)

    [
      %Deck{did: 3, mod: 3, name: "name3"},
      %Deck{did: 4, mod: 4, name: "name4"}
    ] = Repo.all(Deck)
  end

  test "insert_or_update model" do
    attrs1 = %{did: 123, flds: ["Front1", "Back1"], mid: 123, mod: 123, name: "name1"}
    attrs2 = %{did: 456, flds: ["Front2", "Back2"], mid: 456, mod: 456, name: "name2"}

    %Model{}
    |> Model.changeset(attrs1)
    |> Repo.insert!()

    [%Model{did: 123, flds: ["Front1", "Back1"], mid: 123, mod: 123, name: "name1"}] =
      Repo.all(Model)

    Model.insert_or_update!(attrs2)

    [%Model{did: 456, flds: ["Front2", "Back2"], mid: 456, mod: 456, name: "name2"}] =
      Repo.all(Model)

    %Model{did: 789, flds: ["Front3", "Back3"], mid: 789, mod: 789, name: "name3"}
    |> Model.insert_or_update!()

    [%Model{did: 789, flds: ["Front3", "Back3"], mid: 789, mod: 789, name: "name3"}] =
      Repo.all(Model)
  end

  test "insert_or_update list of models" do
    attrs = [
      %{
        did: 1,
        flds: ["Text", "Extra"],
        mid: 1_502_629_924,
        mod: 1_502_629_944,
        name: "Cloze"
      },
      %{
        did: 1,
        flds: ["Front", "Back"],
        mid: 1_507_832_105,
        mod: 1_507_832_120,
        name: "Basic (and reversed card)"
      }
    ]

    Model.insert_or_update!(attrs)

    assert length(Repo.all(Model)) == 2
  end
end
