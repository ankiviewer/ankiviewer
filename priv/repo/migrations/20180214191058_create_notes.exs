defmodule AnkiViewer.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes, primary_key: false) do
      add :cid, :integer
      add :nid, :integer
      add :cmod, :integer
      add :nmod, :integer
      add :mid, :integer
      add :tags, {:array, :string}
      add :flds, :string
      add :sfld, :string
      add :did, :integer
      add :ord, :integer
      add :type, :integer
      add :queue, :integer
      add :due, :integer
      add :reps, :integer
      add :lapses, :integer

      timestamps()
    end

  end
end
