defmodule AnkiViewer.CardTest do
  use AnkiViewer.DataCase, async: false

  test "insert card" do
    attrs = %{
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

    Card.insert!([attrs])

    %Card{} |> Map.merge(%{attrs | cid: 124}) |> Card.insert!()

    assert Card |> Repo.all() |> length == 2
  end
end
