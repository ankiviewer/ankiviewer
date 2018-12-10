defmodule AnkiViewerWeb.RuleRunChannel do
  use AnkiViewerWeb, :channel

  def join("rule:run", %{"rid" => rid}, socket) do
    send(self(), {:rule, :run, %{rid: rid}})

    {:ok, socket}
  end

  def handle_info({:rule, :run, %{rid: rid}}, socket) do
    CardRule
    |> where([cr], cr.rid == ^rid)
    |> Repo.delete_all()

    push(socket, "rule:msg", %{msg: "starting run", percentage: 0, seconds: 0})

    cards = Repo.all(Card)
    rule = Repo.get(Rule, rid)

    cards_length = length(cards)

    cards
    |> Enum.with_index()
    |> Enum.reduce(%{timestamp: DateTime.utc_now(), diff: 0}, fn {card, i},
                                                                 %{
                                                                   timestamp: timestamp,
                                                                   diff: diff
                                                                 } ->
      now = DateTime.utc_now()

      new_diff =
        Integer.floor_div((i + 1) * diff + DateTime.diff(now, timestamp, :microsecond), i + 2)

      push(socket, "rule:msg", %{
        msg: "running rule #{i}/#{length(cards)}",
        percentage: round(i / length(cards) * 100),
        seconds: Integer.floor_div((cards_length - i) * new_diff, 1_000_000)
      })

      %CardRule{cid: card.cid, rid: rid}
      |> Map.merge(
        case CardRule.run(cards, card, rule) do
          :ok ->
            %{fails: false}

          {:error, ""} ->
            %{fails: true}

            # TODO: pass solution along
            # {:error, solution} ->
            #   %{fails: true, solution: solution}
        end
      )
      |> CardRule.insert!()

      %{timestamp: now, diff: new_diff}
    end)

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
