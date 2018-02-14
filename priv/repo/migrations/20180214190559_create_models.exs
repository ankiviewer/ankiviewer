defmodule AnkiViewer.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add :mid, :integer
      add :did, :integer
      add :flds, {:array, :string}
      add :mod, :integer
      add :name, :string

      timestamps()
    end

  end
end
