defmodule AnkiViewer do
  import Utils

  @anki_db_path Application.get_env(:anki_viewer, :anki_db_path)

  defp sqlite_cmd!(sql, header \\ [header: false])
  defp sqlite_cmd!(sql, header: header) do
    h = if header, do: "-header", else: "-noheader"
    case System.cmd("sqlite3", [h, @anki_db_path, sql]) do
      {data, 0} -> data
      e -> raise e
    end
  end

  def collection_data! do
    [crt, mod, models, decks, tags] =
      """
      select crt, mod, models, decks, tags from col
      """
      |> sqlite_cmd!()
      |> String.split("|")

    %{
      crt: sanitize_integer(crt),
      mod: sanitize_integer(mod),
      models: format_models(models),
      decks: format_decks(decks),
      tags: tags |> Jason.decode!() |> Map.keys()
    }
  end

  def format(json) do
    json
    |> Jason.decode!()
    |> Map.values()
    |> Enum.map(
      &(Map.new(&1, fn {k, v} -> {String.to_atom(k), sanitize_integer(v)} end))
    )
  end

  defp format_flds(flds), do: Enum.map(flds, &Map.get(&1, "name"))

  def format_models(models) do
    models
    |> format()
    |> Enum.map(fn m ->
      m |> Map.put(:mid, m.id) |> Map.update!(:flds, &format_flds/1)
    end)
  end

  def format_decks(decks) do
    decks |> format() |> Enum.map(&Map.put(&1, :did, &1.id))
  end

  def notes_data! do
    """
    select
    c.id as cid,
    c.mod as cmod,
    c.did as did,
    c.due as due,
    n.flds as flds,
    c.lapses as lapses,
    n.mid as mid,
    n.id as nid,
    n.mod as nmod,
    c.ord as ord,
    c.queue as queue,
    c.reps as reps,
    n.sfld as sfld,
    n.tags as tags,
    c.type as type
    from notes as n inner join cards as c on n.id = c.nid
    """
    |> sqlite_cmd!(header: true)
    |> format_notes
  end

  def format_notes(notes_data) do
    [keys | notes] =
      notes_data
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "|"))

    notes
    |> Enum.map(fn nd ->
      nd
      |> Enum.with_index()
      |> Map.new(fn {n, i} ->
        case keys |> Enum.at(i) |> String.to_atom() do
          :sfld -> {:sfld, n}
          :flds -> {:flds, n}
          :tags -> {:tags, String.split(n, " ", trim: true)}
          k -> {k, sanitize_integer(n)}
        end
      end)
    end)
  end
end
