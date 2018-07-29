defmodule AnkiViewer.TestHelpers do
  alias AnkiViewer.{Collection, Model, Deck, Note, Repo}

  def configure_sqlite! do
    {"", 0} =
      System.cmd("sqlite3", [
        Application.get_env(:anki_viewer, :anki_db_path),
        ".read #{:code.priv_dir(:anki_viewer)}/anki_test_dump.sql"
      ])
  end

  def load_collection! do
    collection_data = AnkiViewer.collection_data!()

    collection_data
    |> Map.take(~w(crt mod tags)a)
    |> Collection.insert_or_update!()

    collection_data |> Map.fetch!(:models) |> Model.insert_or_update!()
    collection_data |> Map.fetch!(:decks) |> Deck.insert_or_update!()

    Repo.delete_all(Note)

    AnkiViewer.notes_data!() |> Enum.each(&Note.insert!/1)
  end

  def simplify_struct(struct) when is_map(struct) do
    atom_keys = ~w(__meta__ inserted_at updated_at rid id)a
    string_keys = ~w(inserted_at updated_at rid)

    Map.drop(struct, atom_keys ++ string_keys)
  end

  def simplify_struct({:ok, struct}) when is_map(struct) do
    {:ok, simplify_struct(struct)}
  end

  def simplify_struct(list) when is_list(list) do
    Enum.map(list, &simplify_struct/1)
  end
end
