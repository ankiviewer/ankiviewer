defmodule AnkiViewer.CollectionTest do
  use AnkiViewer.DataCase, async: false

  test "insert_or_update a new collection" do
    attrs = %{crt: 123, mod: 123, tags: []}
    %Collection{}
    |> Collection.insert_or_update!(attrs)

    [%Collection{crt: 123, mod: 123, tags: []}] = Repo.all(Collection)
  end

  test "insert_or_update a pre existing collection" do
    attrs1 = %{crt: 123, mod: 123, tags: []}
    attrs2 = %{crt: 456, mod: 456, tags: ["one"]}

    %Collection{}
    |> Collection.changeset(attrs1)
    |> Repo.insert!

    [%Collection{crt: 123, mod: 123, tags: []}] = Repo.all(Collection)

    %Collection{}
    |> Collection.insert_or_update!(attrs2)

    [%Collection{crt: 456, mod: 456, tags: ["one"]}] = Repo.all(Collection)

    %Collection{crt: 789, mod: 789, tags: ["one", "two"]}
    |> Collection.insert_or_update!

    [%Collection{crt: 789, mod: 789, tags: ["one", "two"]}] = Repo.all(Collection)
  end

  test "insert_or_update deck" do
    attrs1 = %{did: 123, mod: 123, name: "name1"}
    attrs2 = %{did: 456, mod: 456, name: "name2"}

    %Deck{}
    |> Deck.changeset(attrs1)
    |> Repo.insert!

    [%Deck{did: 123, mod: 123, name: "name1"}] = Repo.all(Deck)

    %Deck{}
    |> Deck.insert_or_update!(attrs2)

    [%Deck{did: 456, mod: 456, name: "name2"}] = Repo.all(Deck)

    %Deck{did: 789, mod: 789, name: "name3"}
    |> Deck.insert_or_update!

    [%Deck{did: 789, mod: 789, name: "name3"}] = Repo.all(Deck)
  end

  test "insert_or_update model" do
    attrs1 = %{did: 123, flds: ["Front1", "Back1"], mid: 123, mod: 123, name: "name1"}
    attrs2 = %{did: 456, flds: ["Front2", "Back2"], mid: 456, mod: 456, name: "name2"}

    %Model{}
    |> Model.changeset(attrs1)
    |> Repo.insert!

    [%Model{did: 123, flds: ["Front1", "Back1"], mid: 123, mod: 123, name: "name1"}] = Repo.all(Model)

    %Model{}
    |> Model.insert_or_update!(attrs2)

    [%Model{did: 456, flds: ["Front2", "Back2"], mid: 456, mod: 456, name: "name2"}] = Repo.all(Model)

    %Model{did: 789, flds: ["Front3", "Back3"], mid: 789, mod: 789, name: "name3"}
    |> Model.insert_or_update!

    [%Model{did: 789, flds: ["Front3", "Back3"], mid: 789, mod: 789, name: "name3"}] = Repo.all(Model)
  end
end
