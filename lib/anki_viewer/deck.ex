defmodule AnkiViewer.Deck do
  use AnkiViewer.SingleEntry

  @primary_key false
  schema "decks" do
    field(:did, :integer)
    field(:mod, :integer)
    field(:name, :string)

    timestamps()
  end

  @attrs ~w(did name mod)a
  def changeset(%Deck{} = deck, attrs \\ %{}) do
    deck
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
