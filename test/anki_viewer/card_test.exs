defmodule AnkiViewer.CardTest do
  use AnkiViewer.DataCase, async: false

  @card_attrs %{
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

  test "insert card" do
    attrs = @card_attrs

    Card.insert!([attrs])

    %Card{} |> Map.merge(%{attrs | cid: 124}) |> Card.insert!()

    assert Card |> Repo.all() |> length == 2
  end

  test "update card" do
    attrs = @card_attrs

    %{cid: cid} =
      %Card{}
      |> Map.merge(attrs)
      |> Card.changeset()
      |> Repo.insert!()

    Card.update!(%{cid: cid, flds: "onethree", sfld: "three"})

    %{flds: flds, sfld: sfld} = Repo.get(Card, cid)

    assert flds == "onethree"
    assert sfld == "three"
  end
end
