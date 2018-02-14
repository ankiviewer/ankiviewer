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

  @doc false
  def changeset(%Note{} = note, attrs) do
    note
    |> cast(attrs, [:cid, :nid, :cmod, :nmod, :mid, :tags, :flds, :sfld, :did, :ord, :type, :queue, :due, :reps, :lapses])
    |> validate_required([:cid, :nid, :cmod, :nmod, :mid, :tags, :flds, :sfld, :did, :ord, :type, :queue, :due, :reps, :lapses])
  end
end
