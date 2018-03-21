defmodule AnkiViewer.NoteRuleTest do
  use AnkiViewer.DataCase, async: false

  setup do
    Note.update_all()

    passing_rule =
      %{
        name: "sfld not blank",
        code: """
        (_deck, note) => note.sfld !== ''
        """,
        tests: "[]"
      }
      |> Rule.insert!()

    failing_rule =
      %{
        name: "sfld is blank",
        code: """
        (_deck, note) => note.sfld === ''
        """,
        tests: "[]"
      }
      |> Rule.insert!()

    %{passing_rule: passing_rule, failing_rule: failing_rule}
  end

  test "run a note through a passing rule", %{passing_rule: passing_rule} do
    notes = [note | _] = Repo.all(Note)

    assert NoteRule.run(notes, note, passing_rule) == :ok
  end

  test "run a note through a failing rule", %{failing_rule: failing_rule} do
    notes = [note | _] = Repo.all(Note)

    assert NoteRule.run(notes, note, failing_rule) == {:error, ""}
  end

  test "insert a NoteRule" do
    [
      %{
        fails: true,
        nid: 1,
        rid: 1
      }
    ]
    |> NoteRule.insert!()

    [%NoteRule{fails: fails, nid: nid, rid: rid}] = Repo.all(NoteRule)
    assert [fails, nid, rid] == [true, 1, 1]
  end
end
