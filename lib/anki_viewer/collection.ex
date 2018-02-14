defmodule AnkiViewer.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Collection


  schema "collection" do
    field :crt, :integer
    field :mod, :integer
    field :tags, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(%Collection{} = collection, attrs) do
    collection
    |> cast(attrs, [:crt, :mod, :tags])
    |> validate_required([:crt, :mod, :tags])
  end
end
