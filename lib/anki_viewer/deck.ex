defmodule AnkiViewer.Deck do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.Deck


  schema "decks" do
    field :did, :integer
    field :mod, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Deck{} = deck, attrs) do
    deck
    |> cast(attrs, [:did, :name, :mod])
    |> validate_required([:did, :name, :mod])
  end
end
