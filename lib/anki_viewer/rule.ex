defmodule AnkiViewer.Rule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Rule

  schema "rules" do
    field(:code, :string)
    field(:name, :string)
    field(:rid, :integer)

    timestamps()
  end

  @attrs ~w(code name rid)a
  def changeset(%Rule{} = rule, attrs \\ %{}) do
    rule
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
