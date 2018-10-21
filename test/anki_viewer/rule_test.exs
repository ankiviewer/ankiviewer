defmodule AnkiViewer.RuleTest do
  use AnkiViewer.DataCase, async: false
  doctest AnkiViewer.Rule, import: true

  @code """
  card.sfld != ""
  """
  @tests """
  [
    %{
      card: %{sfld: "h"},
      fine: true,
      deck: nil
    },
    %{
      card: %{sfld: ""},
      fine: false,
      deck: nil
    }
  ]
  """

  test "insert rule struct" do
    assert :ok ==
             [
               %{
                 name: "no blank fields",
                 code: @code,
                 tests: @tests
               }
             ]
             |> Rule.insert()
  end

  describe "rule" do
    setup do
      [
        %{
          name: "no duplicate front",
          code: """
          not Enum.any?(deck, fn n ->
            n.sfld == card.sfld and n.nid != card.nid
          end)
          """,
          tests: """
            [
              %{
                deck: [
                  %{nid: 0, sfld: "h"},
                  %{nid: 1, sfld: "hi"}
                ],
                card: %{nid: 0, sfld: "h"},
                fine: true
              },
              %{
                deck: [
                  %{nid: 0, sfld: "h"},
                  %{nid: 1, sfld: "h"}
                ],
                card: %{nid: 0, sfld: "h"},
                fine: true
              }
            ]
          """
        },
        %{
          name: "nouns start with 'the'",
          code: """
          if "noun" in card.tags do
            String.starts_with?(card.sfld, "the ")
          else
            true
          end
          """,
          tests: """
            [
              %{
                card: %{tags: ["noun"], sfld: "h"},
                deck: nil,
                fine: false
              },
              %{
                card: %{tags: [], sfld: "h"},
                deck: nil,
                fine: true
              },
              %{
                card: %{tags: ["noun"], sfld: "the h"},
                deck: nil,
                fine: true
              }
            ]
          """
        }
      ]
      |> Rule.insert!()

      :ok
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

      assert error ==
               ~s(card: %{nid: 0, sfld: "h"} and deck: [%{nid: 0, sfld: "h"}, %{nid: 1, sfld: "h"}] were expected to be ok, but were actually not ok for rule: no duplicate front)
    end
  end

  describe "changeset" do
    test "blank fields" do
      actual = Rule.insert(%{name: ""})

      expected = {
        :error,
        %{
          name: "can't be blank",
          code: "can't be blank",
          tests: "can't be blank"
        }
      }

      assert actual == expected
    end

    test "code syntax error" do
      code = """
      card.sfld != "
      """

      actual = Rule.insert(%{name: "n", code: code, tests: @tests})
      expected = {:error, %{code: "missing terminator: \" (for string starting at line 1)"}}

      assert actual == expected
    end

    test "tests syntax error" do
      tests = """
        [
          %{
            card: %{sfld: "h"},
            fine: true,
            deck: nil
          },
          %{
            card: %{sfld: ""},
            fine: false,
            deck: nil
          }
      """

      actual = Rule.insert(%{name: "n", code: @code, tests: tests})
      expected = {:error, %{tests: "missing terminator: ] (for \"[\" starting at line 1)"}}

      assert actual == expected
    end

    test "code and tests syntax error" do
      code = """
      card.sfld != "
      """

      tests = """
        [
          %{
            card: %{sfld: "h"},
            fine: true,
            deck: nil
          },
          %{
            card: %{sfld: ""},
            fine: false,
            deck: nil
          }
      """

      actual = Rule.insert(%{name: "n", code: code, tests: tests})

      expected =
        {:error,
         %{
           code: "missing terminator: \" (for string starting at line 1)",
           tests: "missing terminator: ] (for \"[\" starting at line 1)"
         }}

      assert actual == expected
    end

    test "valid code, tests and name" do
      rule = %{name: "n", code: @code, tests: @tests}

      actual = Rule.insert(rule)
      expected = {:ok, Map.merge(%Rule{}, rule)}

      assert simplify_struct(actual) == simplify_struct(expected)
    end
  end
end
