defmodule AnkiViewer.Collection do
  use AnkiViewer.SingleRow

  @primary_key false
  schema "collection" do
    field(:crt, :integer)
    field(:mod, :integer)
    field(:tags, {:array, :string})

    timestamps()
  end

  @attrs ~w(crt mod tags)a
  def changeset(%Collection{} = collection, attrs \\ %{}) do
    collection
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
