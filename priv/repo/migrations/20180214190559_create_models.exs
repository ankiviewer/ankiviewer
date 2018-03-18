defmodule AnkiViewer.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models, primary_key: false) do
      add :mid, :integer
      add :did, :integer
      add :flds, {:array, :string}
      add :mod, :integer
      add :name, :string

      timestamps()
    end

  end
end
