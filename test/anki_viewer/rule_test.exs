defmodule AnkiViewer.RuleTest do
  use AnkiViewer.DataCase, async: false

  test "insert rule struct" do
    attrs = %{
      name: "no blank fields",
      code: """
      (_deck, note) => note.sfld !== ""
      """,
      tests:
        [
          %{
            note: %{sfld: "h"},
            fine: true
          },
          %{
            note: %{sfld: ""},
            fine: false
          }
        ]
        |> Jason.encode!()
    }

    %Rule{}
    |> Map.merge(attrs)
    |> Rule.insert!()
  end

  describe "rule" do
    setup do
      attrs = [
        %{
          name: "no duplicate front",
          code: """
          (deck, note) => {
            var fine = true;
            for (var i=0;i<deck.length;i++) {
              if (deck[i].sfld == note.sfld && deck[i].nid != note.nid) {
                fine = false;
                break;
              }
            }
            return fine;
          }
          """,
          tests:
            [
              %{
                deck: [
                  %{nid: 0, sfld: "h"},
                  %{nid: 1, sfld: "hi"}
                ],
                note: %{nid: 0, sfld: "h"},
                fine: true
              },
              %{
                deck: [
                  %{nid: 0, sfld: "h"},
                  %{nid: 1, sfld: "h"}
                ],
                note: %{nid: 0, sfld: "h"},
                fine: true
              }
            ]
            |> Jason.encode!()
        },
        %{
          name: "nouns start with 'the'",
          code: """
          (_deck, note) => note.tags.includes('noun') ? note.sfld.startsWith('the ') : true;
          """,
          tests:
            [
              %{
                note: %{tags: ["noun"], sfld: "h"},
                fine: false
              },
              %{
                note: %{tags: [], sfld: "h"},
                fine: true
              },
              %{
                note: %{tags: ["noun"], sfld: "the h"},
                fine: true
              }
            ]
            |> Jason.encode!()
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

      assert Rule.run_tests(ok_rule) == :ok

      error_rule = Repo.get_by(Rule, name: "no duplicate front")
      {:error, error} = Rule.run_tests(error_rule)

      assert error == ""
    end
  end
end
