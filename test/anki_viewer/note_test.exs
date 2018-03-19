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

  test "update all" do
    Note.update_all()

    notes = [%Note{cid: cid, cmod: cmod, did: did} | _] = Note |> Repo.all()
    assert length(notes) == 10
    assert [cid, cmod, did] == [1_506_600_429, 1_510_927_123, 1_482_060_876]
  end
end
