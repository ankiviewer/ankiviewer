defmodule AnkiViewer.Repo.Migrations.CreateRules do
  use Ecto.Migration

  def change do
    create table(:rules, primary_key: false) do
      add(:rid, :bigserial, primary_key: true)
      add(:name, :string)
      add(:code, :text)
      add(:tests, :text)

      timestamps()
    end
  end
end
