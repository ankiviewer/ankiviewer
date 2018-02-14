defmodule AnkiViewer.Repo.Migrations.CreateDecks do
  use Ecto.Migration

  def change do
    create table(:decks) do
      add :did, :integer
      add :name, :string
      add :mod, :integer

      timestamps()
    end

  end
end
