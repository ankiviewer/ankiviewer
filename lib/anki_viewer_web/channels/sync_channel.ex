defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel
  import Utils

  @anki_db_path Application.get_env(:anki_viewer, :anki_db_path)

  def join("sync:database", _payload, socket) do
    send(self(), {:sync, :database})

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    push(socket, "sync:msg", %{msg: "starting sync"})

    {collection_data, 0} =
      System.cmd("sqlite3", [@anki_db_path, "select crt, mod, models, decks, tags from col"])

    {notes_data, 0} =
      System.cmd("sqlite3", [
        "-header",
        @anki_db_path,
        "select c.id as cid, c.mod as cmod, c.did as did, c.due as due, n.flds as flds, c.lapses as lapses, n.mid as mid, n.id as nid, n.mod as nmod, c.ord as ord, c.queue as queue, c.reps as reps, n.sfld as sfld, n.tags as tags, c.type as type from notes as n inner join cards as c on n.id = c.nid"
      ])

    [crt, mod, models, decks, tags] = String.split(collection_data, "|")

    %Collection{
      crt: sanitize_integer(crt),
      mod: sanitize_integer(mod),
      tags: tags |> Jason.decode!() |> Map.keys()
    }
    |> Collection.insert_or_update!()

    model_attrs =
      models
      |> Jason.decode!()
      |> Map.values()
      |> Enum.map(fn m ->
        m
        |> Map.new(fn {k, v} -> {String.to_atom(k), sanitize_integer(v)} end)
        |> Map.new(fn {k, v} ->
          case k do
            :id -> {:mid, v}
            :flds -> {:flds, Enum.map(v, &Map.get(&1, "name"))}
            _ -> {k, v}
          end
        end)
      end)

    Model.insert_or_update!(model_attrs)

    deck_attrs =
      decks
      |> Jason.decode!()
      |> Map.values()
      |> Enum.map(fn d ->
        d
        |> Map.new(fn {k, v} -> {String.to_atom(k), sanitize_integer(v)} end)
        |> Map.new(fn {k, v} ->
          case k do
            :id -> {:did, v}
            _ -> {k, v}
          end
        end)
      end)

    Deck.insert_or_update!(deck_attrs)

    push(socket, "sync:msg", %{msg: "updated collection"})

    [keys | notes_data] =
      notes_data
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "|"))

    Repo.delete_all(Note)

    notes =
      notes_data
      |> Enum.map(fn nd ->
        nd
        |> Enum.with_index()
        |> Map.new(fn {n, i} ->
          case keys |> Enum.at(i) |> String.to_atom() do
            :sfld -> {:sfld, n}
            :flds -> {:flds, n}
            k -> {k, sanitize_integer(n)}
          end
        end)
        |> Map.update!(:tags, &String.split(&1, " ", trim: true))
      end)

    for {n, i} <- Enum.with_index(notes) do
      push(socket, "sync:msg", %{msg: "updating note #{i}/#{length(notes)}"})
      Note.insert!(n)
    end

    push(socket, "sync:msg", %{msg: "updated notes"})

    push(socket, "done", %{})

    {:noreply, socket}
  end
end
