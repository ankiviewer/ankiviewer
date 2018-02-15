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

  @attrs ~w(mid, did, flds, mod, name)a
  def changeset(%Model{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
