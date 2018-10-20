defmodule AnkiViewer.Repo.Migrations.CreateDatabase do
  use Ecto.Migration

  def change do
    create table(:collection, primary_key: false) do
      add(:crt, :bigint)
      add(:mod, :bigint)
      add(:tags, {:array, :string})

      timestamps()
    end

    create table(:models, primary_key: false) do
      add(:mid, :bigint)
      add(:did, :bigint)
      add(:flds, {:array, :string})
      add(:mod, :bigint)
      add(:name, :string)

      timestamps()
    end

    create table(:decks, primary_key: false) do
      add(:did, :bigint)
      add(:name, :string)
      add(:mod, :bigint)

      timestamps()
    end

    create table(:cards, primary_key: false) do
      add(:cid, :bigint, primary_key: true)
      add(:nid, :bigint)
      add(:cmod, :bigint)
      add(:nmod, :bigint)
      add(:mid, :bigint)
      add(:tags, {:array, :string})
      add(:flds, :text)
      add(:sfld, :text)
      add(:did, :bigint)
      add(:ord, :bigint)
      add(:type, :bigint)
      add(:queue, :bigint)
      add(:due, :bigint)
      add(:reps, :bigint)
      add(:lapses, :bigint)

      timestamps()
    end

    create table(:rules, primary_key: false) do
      add(:rid, :serial, primary_key: true)
      add(:name, :string)
      add(:code, :text)
      add(:tests, :text)

      timestamps()
    end

    create table(:card_rules) do
      add(:cid, :bigint)
      add(:rid, :id)
      add(:fails, :boolean, default: false, null: false)
      add(:comment, :string)
      add(:url, :string)
      add(:ignore, :boolean, default: false, null: false)
      add(:solution, :string)

      timestamps()
    end
  end
end
