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
end
