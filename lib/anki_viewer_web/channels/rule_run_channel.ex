defmodule AnkiViewerWeb.RuleRunChannel do
  use AnkiViewerWeb, :channel

  def join("run:rule", %{"rid" => rid}, socket) do
    send(self(), {:run, :rule, %{rid: rid}})

    {:ok, socket}
  end

  def handle_info({:run, :rule, %{rid: rid}}, socket) do
    push(socket, "run:msg", %{msg: "starting run"})

    cards = Repo.all(Card)
    rule = Repo.get(Rule, rid)

    for c <- cards do
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
