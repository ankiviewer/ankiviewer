defmodule AnkiViewer.Note do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Note


  schema "notes" do
    field :cid, :integer
    field :cmod, :integer
    field :did, :integer
    field :due, :integer
    field :flds, :string
    field :lapses, :integer
    field :mid, :integer
    field :nid, :integer
    field :nmod, :integer
    field :ord, :integer
    field :queue, :integer
    field :reps, :integer
    field :sfld, :string
    field :tags, {:array, :string}
    field :type, :integer

    timestamps()
  end

  @attrs ~w(cid, nid, cmod, nmod, mid, tags, flds, sfld, did, ord, type, queue, due, reps, lapses)a
  def changeset(%Note{} = note, attrs \\ %{}) do
    note
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
