defmodule AnkiViewer.Repo.Migrations.CreateNoteRules do
  use Ecto.Migration

  def change do
    create table(:note_rules) do
      add :nid, :integer
      add :rid, :integer
      add :fails, :boolean, default: false, null: false
      add :comment, :string
      add :url, :string
      add :ignore, :boolean, default: false, null: false
      add :solution, :string

      timestamps()
    end

  end
end
