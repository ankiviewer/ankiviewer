defmodule AnkiViewer.Model do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Model


  schema "models" do
    field :did, :integer
    field :flds, {:array, :string}
    field :mid, :integer
    field :mod, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Model{} = model, attrs) do
    model
    |> cast(attrs, [:mid, :did, :flds, :mod, :name])
    |> validate_required([:mid, :did, :flds, :mod, :name])
  end
end
