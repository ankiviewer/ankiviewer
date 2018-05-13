defmodule AnkiViewerWeb.PageController do
  use AnkiViewerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def collection(conn, _params) do
    case Repo.one(Collection) do
      nil ->
        json(conn, %{mod: 0, notes: 0})

      %{mod: mod} ->
        notes = Note |> Repo.all() |> length()
        json(conn, %{mod: mod, notes: notes})
    end
  end

  def notes(conn, %{"deck" => deck, "model" => model, "modelorder" => modelorder, "rule" => rule, "search" => search, "tags" => tags}) do
    notes = Note
    |> join(:inner, [n], m in Model, n.mid == m.mid)
    |> join(:inner, [n, m], d in Deck, n.did == d.did)
    |> select(
      [n, m, d],
      %{
        model: m.name,
        tags: n.tags,
        deck: d.name,
        type: n.type,
        queue: n.queue,
        due: n.due,
        reps: n.reps,
        lapses: n.lapses,
        flds: n.flds,
        sfld: n.sfld,
        ord: n.ord
      }
    )
    |> where([n, m, d], like(n.flds, ^"%#{search}%"))
    |> deck_query(deck)
    |> model_query(model)
    |> Repo.all()

    json(conn, notes)
  end

  def notes(conn, params) do
    # TODO:improve this

    json(conn, %{error: "BAD PARAMS"})
  end

  defp deck_query(q, deck) do
    case deck do
      "" ->
        q
      _ ->
        where(q, [n, m, d], d.name == ^deck)
    end
  end

  defp model_query(q, model) do
    case model do
      "" ->
        q
      _ ->
        where(q, [n, m, d], m.name == ^model)
    end
  end
end
