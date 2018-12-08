defmodule AnkiViewerWeb.RuleRunChannelTest do
  use AnkiViewerWeb.ChannelCase, async: false
  alias AnkiViewerWeb.RuleRunChannel

  describe "run:rule" do
    test "with no failing cards" do
      %{rid: rid} =
        %{
          name: "no blank fields",
          code: ~s(card.sfld != ""),
          tests: "[]"
        }
        |> Rule.insert!()

      load_collection!()

      assert Repo.all(CardRule) == []

      {:ok, _, _socket} =
        subscribe_and_join(socket(), RuleRunChannel, "run:rule", %{"rid" => rid})

      assert_push("run:msg", %{msg: "starting run"})

      assert_push("done", %{})

      cards = Repo.all(CardRule)

      assert length(cards) == 10
      assert Enum.all?(cards, &(not &1.fails))
    end

    test "with failing cards" do
      %{rid: rid} =
        %{
          name: "only blank fields",
          code: ~s(card.sfld == ""),
          tests: "[]"
        }
        |> Rule.insert!()

      load_collection!()

      assert Repo.all(CardRule) == []

      {:ok, _, _socket} =
        subscribe_and_join(socket(), RuleRunChannel, "run:rule", %{"rid" => rid})

      assert_push("run:msg", %{msg: "starting run"})

      assert_push("done", %{})

      cards = Repo.all(CardRule)

      assert length(cards) == 10
      assert Enum.all?(cards, &(&1.fails))
    end

    test "ensure no duplicates" do
      %{rid: rid} =
        %{
          name: "no duplicate sfld",
          code: "Enum.any?(cards, fn %{nid: nid, sfld: sfld} -> sfld == card.sfld and card.nid != nid end)",
          tests: "[]"
        }
        |> Rule.insert!()

      load_collection!()

      generous_card = Card |> Repo.all() |> Enum.find(fn %{sfld: sfld} -> sfld == "generous" end)

      Card.insert!(%{ generous_card | cid: generous_card.cid + 1, nid: generous_card.nid + 1 })

      {:ok, _, _socket} =
        subscribe_and_join(socket(), RuleRunChannel, "run:rule", %{"rid" => rid})

      assert_push("run:msg", %{msg: "starting run"})

      assert_push("done", %{})

      card_rules = Repo.all(CardRule)

      assert length(card_rules) == 11
      assert length(Enum.filter(card_rules, &Map.get(&1, :fails))) == 8
      assert length(Enum.filter(card_rules, &(not Map.get(&1, :fails)))) == 3
    end
  end
end
