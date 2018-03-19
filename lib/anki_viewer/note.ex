defmodule AnkiViewer.Note do
  use Ecto.Schema
  import Ecto.Changeset
  import Utils
  alias AnkiViewer.{Note, Repo}

  @anki_db_path Application.get_env(:anki_viewer, :anki_db_path)

  @primary_key false
  schema "notes" do
    field(:cid, :integer)
    field(:cmod, :integer)
    field(:did, :integer)
    field(:due, :integer)
    field(:flds, :string)
    field(:lapses, :integer)
    field(:mid, :integer)
    field(:nid, :integer)
    field(:nmod, :integer)
    field(:ord, :integer)
    field(:queue, :integer)
    field(:reps, :integer)
    field(:sfld, :string)
    field(:tags, {:array, :string})
    field(:type, :integer)

    timestamps()
  end

  @attrs ~w(cid nid cmod nmod mid tags flds sfld did ord type queue due reps lapses)a
  def changeset(%Note{} = note, attrs \\ %{}) do
    note
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  def insert!(attrs) when is_map(attrs) do
    attrs
    |> Map.has_key?(:__struct__)
    |> case do
      true -> attrs
      false -> Map.merge(%Note{}, attrs)
    end
    |> changeset
    |> Repo.insert!()
  end

  def insert!(list) when is_list(list), do: list |> Enum.each(&insert!/1)

  def update_all do
    Repo.delete_all(Note)

    sql =
      "select c.id as cid, c.mod as cmod, c.did as did, c.due as due, n.flds as flds, c.lapses as lapses, n.mid as mid, n.id as nid, n.mod as nmod, c.ord as ord, c.queue as queue, c.reps as reps, n.sfld as sfld, n.tags as tags, c.type as type from notes as n inner join cards as c on n.id = c.nid"

    {notes_string, 0} = System.cmd("sqlite3", [@anki_db_path, sql])

    for note_string <- notes_string |> String.split("\n") |> Enum.filter(&(&1 != "")) do
      [cid, cmod, did, due, flds, lapses, mid, nid, nmod, ord, queue, reps, sfld, tags, type] =
        String.split(note_string, "|")

      tags =
        tags
        |> String.split(" ")
        |> Enum.map(&String.trim/1)
        |> Enum.filter(&(&1 != ""))

      attrs = %{
        cid: sanitize_integer(cid),
        cmod: sanitize_integer(cmod),
        did: sanitize_integer(did),
        due: sanitize_integer(due),
        flds: flds,
        lapses: sanitize_integer(lapses),
        mid: sanitize_integer(mid),
        nid: sanitize_integer(nid),
        nmod: sanitize_integer(nmod),
        ord: sanitize_integer(ord),
        queue: sanitize_integer(queue),
        reps: sanitize_integer(reps),
        sfld: sfld,
        tags: tags,
        type: sanitize_integer(type)
      }

      %Note{}
      |> Map.merge(attrs)
      |> changeset
      |> Repo.insert!()
    end
  end
end
