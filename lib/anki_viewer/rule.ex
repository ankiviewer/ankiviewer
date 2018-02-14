defmodule AnkiViewer.Rule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Rule


  schema "rules" do
    field :code, :string
    field :name, :string
    field :rid, :integer

    timestamps()
  end

  @doc false
  def changeset(%Rule{} = rule, attrs) do
    rule
    |> cast(attrs, [:rid, :name, :code])
    |> validate_required([:rid, :name, :code])
  end
end
