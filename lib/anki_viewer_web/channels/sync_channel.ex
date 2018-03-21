defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel
  import Utils

  @anki_db_path Application.get_env(:anki_viewer, :anki_db_path)

  def join("sync:database", _payload, socket) do
    # A hack to extend the socket timeout, see:
    # https://stackoverflow.com/questions/49331141/configure-channel-test-timeout-phoenix/49335536
    Process.send_after(self(), {:sync, :database}, 0)

    {:ok, socket}
  end

  def handle_info({:sync, :database}, socket) do
    {x, 0} = System.cmd("sqlite3", [@anki_db_path, "select * from col"])

    {_y, 0} =
      System.cmd("sqlite3", [
        @anki_db_path,
        "select c.id as cid, c.mod as cmod, c.did as did, c.due as due, n.flds as flds, c.lapses as lapses, n.mid as mid, n.id as nid, n.mod as nmod, c.ord as ord, c.queue as queue, c.reps as reps, n.sfld as sfld, n.tags as tags, c.type as type from notes as n inner join cards as c on n.id = c.nid"
      ])

    [crt, mod, models, decks, tags] = String.split(x, "|")

    %Collection{
      crt: String.to_integer(crt),
      mod: mod |> String.to_integer() |> sanitize_integer(),
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

    push(socket, "updating collection", %{})

    {:noreply, socket}
  end
end
