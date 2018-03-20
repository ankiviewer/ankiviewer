defmodule AnkiViewer.Rule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.{Rule, Repo}

  @primary_key {:rid, :id, autogenerate: true}
  schema "rules" do
    field(:code, :string)
    field(:tests, :string)
    field(:name, :string)

    timestamps()
  end

  @attrs ~w(code name tests)a
  def changeset(%Rule{} = rule, attrs \\ %{}) do
    rule
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  def insert!(attrs) when is_map(attrs) do
    attrs
    |> Map.has_key?(:__struct__)
    |> case do
      true -> attrs
      false -> Map.merge(%Rule{}, attrs)
    end
    |> changeset
    |> Repo.insert!()
  end

  def insert!(list) when is_list(list), do: list |> Enum.each(&insert!/1)
end
