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

  @required_params ~w(fails nid rid)a
  @optional_params ~w(comment solution url ignore)a
  def changeset(%NoteRule{} = note_rule, attrs) do
    note_rule
    |> cast(attrs, @required_params ++ @optional_params)
    |> validate_required(@required_params)
  end
end
