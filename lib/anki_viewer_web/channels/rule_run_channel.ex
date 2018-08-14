defmodule AnkiViewerWeb.RuleRunChannel do
  use AnkiViewerWeb, :channel

  def join("run:rule", %{"rid" => rid}, socket) do
    send(self(), {:run, :rule, %{rid: rid}})

    {:ok, socket}
  end

  def handle_info({:run, :rule, %{rid: rid}}, socket) do
    push(socket, "run:msg", %{msg: "starting run"})

    rule = Repo.get(Rule, rid)
    note_rules = Repo.all(NoteRule)
    notes = Repo.all(Note)

    notes
    |> Enum.filter(fn %{nid: nid} ->
      nid not in Enum.map(note_rules, &Map.get(&1, :nid))
    end)
    |> Enum.each(fn %{nid: nid} = n ->
      %NoteRule{nid: nid, rid: rid}
      |> Map.merge(case NoteRule.run(notes, n, rule) do
        :ok ->
          %{fails: false}
        {:error, ""} ->
          %{fails: true}
        {:error, solution} ->
          %{fails: true, solution: solution}
      end)
      |> NoteRule.insert!()
    end)

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
