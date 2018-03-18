defmodule AnkiViewer.Repo.Migrations.CreateCollection do
  use Ecto.Migration

  def change do
    create table(:collection, primary_key: false) do
      add :crt, :integer
      add :mod, :integer
      add :tags, {:array, :string}

      timestamps()
    end

  end
end
