defmodule AnkiViewer.NoteTest do
  use AnkiViewer.DataCase, async: false
  alias AnkiViewer.{Note, Repo}

  test "insert note" do
    attrs = [
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
    ]

    Note.insert!(attrs)

    [%Note{cid: cid}] = Repo.all(Note)
    assert cid == 123
  end

  test "insert notes" do
  end
end
