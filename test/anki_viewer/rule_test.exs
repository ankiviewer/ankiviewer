defmodule AnkiViewer.RuleTest do
  use AnkiViewer.DataCase, async: false
  doctest AnkiViewer.Rule, import: true

  @code """
  note.sfld != ""
  """
  @tests """
  [
    %{
      note: %{sfld: "h"},
      fine: true,
      deck: nil
    },
    %{
      note: %{sfld: ""},
      fine: false,
      deck: nil
    }
  ]
  """

  test "insert rule struct" do
    %{
      name: "no blank fields",
      code: @code,
      tests: @tests
    }
    |> Rule.insert!()
  end

  describe "rule" do
    setup do
      [
        %{
          name: "no duplicate front",
          code: """
          not Enum.any?(deck, fn n ->
            n.sfld == note.sfld and n.nid != note.nid
          end)
          """,
          tests: """
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
          """
        },
        %{
          name: "nouns start with 'the'",
          code: """
          if "noun" in note.tags do
            String.starts_with?(note.sfld, "the ")
          else
            true
          end
          """,
          tests: """
            [
              %{
                note: %{tags: ["noun"], sfld: "h"},
                deck: nil,
                fine: false
              },
              %{
                note: %{tags: [], sfld: "h"},
                deck: nil,
                fine: true
              },
              %{
                note: %{tags: ["noun"], sfld: "the h"},
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
               ~s(note: %{nid: 0, sfld: "h"} and deck: [%{nid: 0, sfld: "h"}, %{nid: 1, sfld: "h"}] were expected to be ok, but were actually not ok for rule: no duplicate front)
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
      note.sfld != "
      """

      actual = Rule.insert(%{name: "n", code: code, tests: @tests})
      expected = {:error, %{code: "missing terminator: \" (for string starting at line 1)"}}

      assert actual == expected
    end

    test "tests syntax error" do
      tests = """
        [
          %{
            note: %{sfld: "h"},
            fine: true,
            deck: nil
          },
          %{
            note: %{sfld: ""},
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
      note.sfld != "
      """

      tests = """
        [
          %{
            note: %{sfld: "h"},
            fine: true,
            deck: nil
          },
          %{
            note: %{sfld: ""},
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
