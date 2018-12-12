defmodule AnkiViewer.CardRuleTest do
  use AnkiViewer.DataCase, async: false

  setup do
    load_collection!()

    passing_rule =
      %{
        name: "sfld not blank",
        code: """
        card.sfld != ""
        """,
        tests: "[]"
      }
      |> Rule.insert!()

    failing_rule =
      %{
        name: "sfld is blank",
        code: """
        card.sfld == ""
        """,
        tests: "[]"
      }
      |> Rule.insert!()

    %{passing_rule: passing_rule, failing_rule: failing_rule}
  end

  test "run a card through a passing rule", %{passing_rule: passing_rule} do
    cards = [card | _] = Repo.all(Card)

    assert CardRule.run(cards, card, passing_rule.code) == :ok
  end

  test "run a card through a failing rule", %{failing_rule: failing_rule} do
    cards = [card | _] = Repo.all(Card)

    assert CardRule.run(cards, card, failing_rule.code) == {:error, ""}
  end

  test "insert a CardRule" do
    attrs = %{fails: true, cid: 1, rid: 1}
    [attrs] |> CardRule.insert!()
    %CardRule{} |> Map.merge(attrs) |> CardRule.insert!()

    [%CardRule{fails: fails, cid: cid, rid: rid}, %CardRule{fails: fails, cid: cid, rid: rid}] =
      Repo.all(CardRule)

    assert [fails, cid, rid] == [true, 1, 1]
  end
end
