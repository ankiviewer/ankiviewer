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

  def notes(conn, %{
        "deck" => deck,
        "model" => model,
        "modelorder" => _modelorder,
        "rule" => _rule,
        "search" => search,
        "tags" => _tags
      }) do
    notes =
      Note
      |> join(:inner, [n], m in Model, n.mid == m.mid)
      |> join(:inner, [n, m], d in Deck, n.did == d.did)
      |> select([n, m, d], %{
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
        ord: n.ord,
        mod: n.nmod
      })
      |> where([n, m, d], like(n.flds, ^"%#{search}%"))
      |> deck_query(deck)
      |> model_query(model)
      |> Repo.all()
      |> extra_fields()
      |> Enum.take(10)

    json(conn, notes)
  end

  def notes(conn, _params) do
    # TODO:improve this

    json(conn, %{error: "BAD PARAMS"})
  end

  @doc """
  iex>extra_fields(%{flds: "hiworld", sfld: "world", type: 0})
  %{flds: "hiworld", sfld: "world", front: "hi", back: "world", type: 0, ttype: 0}

  """
  def extra_fields(%{flds: flds, sfld: sfld, type: type} = map) do
    map
    |> Map.merge(%{front: String.replace_suffix(flds, sfld, ""), back: sfld, ttype: type})
  end

  def extra_fields(list) when is_list(list), do: Enum.map(list, &extra_fields/1)

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
