defmodule AnkiViewerWeb.RuleRunChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false
  alias AnkiViewerWeb.RuleRunChannel

  describe "run:rule" do
    test "with all correct notes" do
      %{rid: rid} = %{
        name: "no blank fields",
        code: ~s(note.sfld != ""),
        tests: "[]"
      }
      |> Rule.insert!()

      load_collection!()

      assert Repo.all(NoteRule) == []

      {:ok, _, _socket} = subscribe_and_join(socket(), RuleRunChannel, "run:rule", %{"rid" => rid})

      assert_push("run:msg", %{msg: "starting run"})

      assert_push("done", %{})

      notes = Repo.all(NoteRule)

      assert length(notes) == 10
      assert Enum.all?(notes, &(not &1.fails))
    end

    test "with failing notes and no duplicates" do
      %{rid: rid} = %{
        name: "only blank fields",
        code: ~s(note.sfld == ""),
        tests: "[]"
      }
      |> Rule.insert!()

      load_collection!()

      assert Repo.all(NoteRule) == []

      {:ok, _, _socket} = subscribe_and_join(socket(), RuleRunChannel, "run:rule", %{"rid" => rid})

      assert_push("run:msg", %{msg: "starting run"})

      assert_push("done", %{})

      note_rules = Repo.all(NoteRule)

      assert length(note_rules) == 10
      assert Enum.all?(note_rules, &(&1.fails))

      {:ok, _, _socket} = subscribe_and_join(socket(), RuleRunChannel, "run:rule", %{"rid" => rid})

      assert_push("run:msg", %{msg: "starting run"})

      assert_push("done", %{})

      note_rules = Repo.all(NoteRule)

      assert length(note_rules) == 10
    end
  end
end
