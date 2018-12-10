defmodule AnkiViewerWeb.RuleRunChannel do
  use AnkiViewerWeb, :channel

  def join("run:rule", %{"rid" => rid}, socket) do
    send(self(), {:run, :rule, %{rid: rid}})

    {:ok, socket}
  end

  def handle_info({:run, :rule, %{rid: rid}}, socket) do
    CardRule
    |> where([cr], cr.rid == ^rid)
    |> Repo.delete_all()

    push(socket, "run:msg", %{msg: "starting run", percentage: 0, seconds: 0})

    cards = Repo.all(Card)
    rule = Repo.get(Rule, rid)

    cards_length = length(cards)

    cards
    |> Enum.with_index()
    |> Enum.reduce(%{timestamp: DateTime.utc_now()}, fn {card, i}, %{timestamp: timestamp} ->
      now = DateTime.utc_now()

      push(socket, "run:msg", %{
        msg: "running rule #{i}/#{length(cards)}",
        percentage: round(i / length(cards) * 100),
        seconds: Integer.floor_div((cards_length - i) * DateTime.diff(now, timestamp, :microsecond), 1000000)
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

      %{timestamp: now}
    end)

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
