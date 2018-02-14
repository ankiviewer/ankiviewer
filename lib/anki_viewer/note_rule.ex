defmodule AnkiViewer.NoteRule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.NoteRule


  schema "note_rules" do
    field :comment, :string
    field :fails, :boolean, default: false
    field :ignore, :boolean, default: false
    field :nid, :integer
    field :rid, :integer
    field :solution, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(%NoteRule{} = note_rule, attrs) do
    note_rule
    |> cast(attrs, [:nid, :rid, :fails, :comment, :url, :ignore, :solution])
    |> validate_required([:nid, :rid, :fails, :comment, :url, :ignore, :solution])
  end
end
