defmodule AnkiViewer.Repo.Migrations.CreateRules do
  use Ecto.Migration

  def change do
    create table(:rules, primary_key: false) do
      add :rid, :integer
      add :name, :string
      add :code, :text

      timestamps()
    end

  end
end
