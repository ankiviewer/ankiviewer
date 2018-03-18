defmodule AnkiViewerWeb.SyncChannel do
  use AnkiViewerWeb, :channel

  @anki_db_path Application.get_env(:anki_viewer, :anki_db_path)

  def join("sync:database", _payload, socket) do
    #  hack to extend the socket timeout, see:
    # https://stackoverflow.com/questions/49331141/configure-channel-test-timeout-phoenix/49335536
    Process.send_after(self(), {:sync, :database}, 0)

    {:ok, socket}
  end

  defp sanitize_integer(i) when is_integer(i) do
    case i |> Integer.digits() |> length do
      1 -> i
      10 -> i
      13 -> trunc(i / 1000)
      _ -> raise "wrong sized integer given"
    end
  end

  defp sanitize_integer(i), do: i

  def handle_info({:sync, :database}, socket) do
    {x, 0} = System.cmd("sqlite3", [@anki_db_path, "select * from col"])

    {_y, 0} =
      System.cmd("sqlite3", [
        @anki_db_path,
        "select c.id as cid, c.mod as cmod, c.did as did, c.due as due, n.flds as flds, c.lapses as lapses, n.mid as mid, n.id as nid, n.mod as nmod, c.ord as ord, c.queue as queue, c.reps as reps, n.sfld as sfld, n.tags as tags, c.type as type from notes as n inner join cards as c on n.id = c.nid"
      ])

    push(socket, "updating collection", %{})
    [crt, mod, models, decks, tags] = String.split(x, "|")

    %Collection{
      crt: String.to_integer(crt),
      mod: mod |> String.to_integer() |> Kernel./(1000) |> trunc,
      tags: tags |> Jason.decode!() |> Map.keys()
    }
    |> Collection.insert_or_update!()

    model_attrs =
      models
      |> Jason.decode!()
      |> Map.values()
      |> Enum.map(fn m ->
        m
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        |> Map.new(fn {k, v} ->
          if k == :id do
            {:mid, v}
          else
            {k, v}
          end
        end)
        |> Map.new(fn {k, v} -> {k, sanitize_integer(v)} end)
        |> Map.update!(:flds, fn f -> Enum.map(f, fn k -> Map.get(k, "name") end) end)
      end)

    %Model{}
    |> Model.insert_or_update!(model_attrs)

    deck_attrs =
      decks
      |> Jason.decode!()
      |> Map.values()
      |> Enum.map(fn d ->
        d
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        |> Map.new(fn {k, v} ->
          {if k == :id do
             :did
           else
             k
           end, v}
        end)
        |> Map.new(fn {k, v} -> {k, sanitize_integer(v)} end)
      end)

    %Deck{}
    |> Deck.insert_or_update!(deck_attrs)

    push(socket, "updated collection", %{})

    {:noreply, socket}
  end
end
