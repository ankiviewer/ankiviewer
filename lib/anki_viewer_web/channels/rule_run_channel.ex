defmodule AnkiViewerWeb.RuleRunChannel do
  use AnkiViewerWeb, :channel

  def join("run:rule", %{"rid" => rid}, socket) do
    send(self(), {:run, :rule, %{rid: rid}})

    {:ok, socket}
  end

  def handle_info({:run, :rule, %{rid: rid}}, socket) do
    push(socket, "run:msg", %{msg: "starting run"})

    notes = Repo.all(Note)
    rule = Repo.get(Rule, rid)

    for n <- notes do
      %NoteRule{nid: n.nid, rid: rid}
      |> Map.merge(
        case NoteRule.run(notes, n, rule) do
          :ok ->
            %{fails: false}

          {:error, ""} ->
            %{fails: true}

          {:error, solution} ->
            %{fails: true, solution: solution}
        end
      )
      |> NoteRule.insert!()
    end

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
