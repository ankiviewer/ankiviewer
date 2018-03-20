defmodule AnkiViewer.Rule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Rule

  @primary_key {:rid, :id, autoincrement: true}
  schema "rules" do
    field(:code, :string)
    field(:tests, :string)
    field(:name, :string)

    timestamps()
  end

  @attrs ~w(code name tests)a
  def changeset(%Rule{} = rule, attrs \\ %{}) do
    rule
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
