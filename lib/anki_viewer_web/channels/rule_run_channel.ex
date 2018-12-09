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

    push(socket, "run:msg", %{msg: "starting run", percentage: 0})

    cards = Repo.all(Card)
    rule = Repo.get(Rule, rid)

    for {c, i} <- Enum.with_index(cards) do
      push(socket, "run:msg", %{
        msg: "running rule #{i}/#{length(cards)}",
        percentage: round(i / length(cards) * 100)
      })

      %CardRule{cid: c.cid, rid: rid}
      |> Map.merge(
        case CardRule.run(cards, c, rule) do
          :ok ->
            %{fails: false}

          {:error, ""} ->
            %{fails: true}

          {:error, solution} ->
            %{fails: true, solution: solution}
        end
      )
      |> CardRule.insert!()
    end

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
