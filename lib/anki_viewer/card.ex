defmodule AnkiViewer.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.{Card, Repo}

  @primary_key {:cid, :integer, []}
  schema "cards" do
    field(:nid, :integer)
    field(:cmod, :integer)
    field(:did, :integer)
    field(:due, :integer)
    field(:flds, :string)
    field(:lapses, :integer)
    field(:mid, :integer)
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
  def changeset(%Card{} = card, attrs \\ %{}) do
    card
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  def insert!(attrs) when is_map(attrs) do
    %Card{}
    |> Map.merge(attrs)
    |> changeset()
    |> Repo.insert!()
  end

  def insert!(list) when is_list(list), do: Enum.each(list, &insert!/1)

  def update!(attrs) when is_map(attrs) do
    Card
    |> Repo.get(attrs.cid)
    |> changeset(attrs)
    |> Repo.update!()
  end
end
