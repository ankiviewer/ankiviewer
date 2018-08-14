defmodule AnkiViewer.Repo.Migrations.CreateDb do
  use Ecto.Migration

  def change do
    create table(:collection, primary_key: false) do
      add(:crt, :integer)
      add(:mod, :integer)
      add(:tags, {:array, :string})

      timestamps()
    end

    create table(:models, primary_key: false) do
      add(:mid, :integer)
      add(:did, :integer)
      add(:flds, {:array, :string})
      add(:mod, :integer)
      add(:name, :string)

      timestamps()
    end

    create table(:decks, primary_key: false) do
      add(:did, :integer)
      add(:name, :string)
      add(:mod, :integer)

      timestamps()
    end

    create table(:notes, primary_key: false) do
      add(:cid, :integer)
      add(:nid, :integer, primary_key: true)
      add(:cmod, :integer)
      add(:nmod, :integer)
      add(:mid, :integer)
      add(:tags, {:array, :string})
      add(:flds, :text)
      add(:sfld, :text)
      add(:did, :integer)
      add(:ord, :integer)
      add(:type, :integer)
      add(:queue, :integer)
      add(:due, :integer)
      add(:reps, :integer)
      add(:lapses, :integer)

      timestamps()
    end

    create unique_index(:notes, [:nid])

    create table(:rules, primary_key: false) do
      add(:rid, :bigserial, primary_key: true)
      add(:name, :string)
      add(:code, :text)
      add(:tests, :text)

      timestamps()
    end

    create table(:note_rules) do
      add(:nid, :integer)
      add(:rid, :integer)
      add(:fails, :boolean, default: false, null: false)
      add(:comment, :string)
      add(:url, :string)
      add(:ignore, :boolean, default: false, null: false)
      add(:solution, :string)

      timestamps()
    end

    create table(:meta) do
      add(:last_update_time, :integer)
    end
  end
end
