defmodule AnkiViewer.RuleTest do
  use AnkiViewer.DataCase, async: false

  describe "rule" do
    setup do
      attrs = [
        %{
          name: "no duplicate front",
          code: """
          (deck, note) => {
            var fine = true;
            for (var i=0;i<=deck.length;i++) {
              if (deck[i].sfld == note.sfld && deck[i].nid != note.nid) {
                fine = false;
                break;
              }
            }
            return fine;
          }
          """,
          tests: """
          [
            {
              "deck": [
                {"nid": 0, "sfld": "h"},
                {"nid": 1, "sfld": "hi"}
              ],
              "note": {"nid": 0, "sfld": "h"},
              "fine": true
            },
            {
              "deck": [
                {"nid": 0, "sfld": "h"},
                {"nid": 1, "sfld": "h"},
              ],
              "note": {"nid": 0, "sfld": "h"},
              "fine": true
            }
          ]
          """
        },
        %{
          name: "nouns start with 'the'",
          code: """
          (_deck, note) => {
            if (note.tags.includes('noun')) {
              return note.sfld.startsWith('the ')
            } else {
              return true;
            }
          }
          """,
          tests: """
          [
            {
              "note": {"tags": ["noun"], "sfld": "h"},
              "fine": false
            },
            {
            "note": {"tags": [], "sfld": "h"},
            "fine": true
            },
            {
            "note": {"tags": ["noun"], "sfld": "the h"},
            "fine": true
            }
          ]
          """
        }
      ]

      Rule.insert!(attrs)
    end

    test "insert" do
      [%Rule{name: name} | _] = Repo.all(Rule)
      assert name == "no duplicate front"
    end

    test "run tests through code" do
      ok_rule = Repo.get_by(Rule, name: "nouns start with 'the'")

      {:ok, ""} = Rule.run_tests(ok_rule)

      error_rule = Repo.get_by(Rule, name: "no duplicate front")

      {:error, error} = Rule.run_tests(error_rule)

      assert error == ""
    end
  end
end
