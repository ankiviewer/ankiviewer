defmodule AnkiViewer.Note do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.{Note, Repo}

  @primary_key false
  schema "notes" do
    field(:cid, :integer)
    field(:cmod, :integer)
    field(:did, :integer)
    field(:due, :integer)
    field(:flds, :string)
    field(:lapses, :integer)
    field(:mid, :integer)
    field(:nid, :integer, primary_key: true)
    field(:nmod, :integer)
    field(:ord, :integer)
    field(:queue, :integer)
    field(:reps, :integer)
    field(:sfld, :string)
    field(:tags, {:array, :string}, default: [])
    field(:type, :integer)

    timestamps()
  end

  @attrs ~w(cid nid cmod nmod mid tags flds sfld did ord type queue due reps lapses)a
  def changeset(%Note{} = note, attrs \\ %{}) do
    note
    |> cast(attrs, @attrs)
    |> unique_constraint(:nid)
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

  def insert!(list) when is_list(list), do: Enum.each(list, &insert!/1)

  def update_all do
    Repo.delete_all(Note)

    Enum.each(AnkiViewer.notes_data!(), &insert!/1)
  end

  def delete!(%{nid: nid}) do
    %Note{
      nid: nid,
      cid: 0,
      cmod: 0,
      did: 0,
      due: 0,
      flds: "",
      lapses: 0,
      mid: 0,
      nmod: 0,
      ord: 0,
      queue: 0,
      reps: 0,
      sfld: "",
      tags: [],
      type: 0
    }
    |> Repo.delete!()
  end
end
