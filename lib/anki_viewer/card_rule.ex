defmodule AnkiViewer.CardRule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.{Card, Rule, CardRule, Repo}

  schema "card_rules" do
    field(:comment, :string)
    field(:fails, :boolean, default: false)
    field(:ignore, :boolean, default: false)
    field(:cid, :integer)
    field(:rid, :integer)
    field(:solution, :string)
    field(:url, :string)

    timestamps()
  end

  @required_params ~w(fails cid rid)a
  @optional_params ~w(comment solution url ignore)a
  def changeset(%CardRule{} = card_rule, attrs \\ %{}) do
    card_rule
    |> cast(attrs, @required_params ++ @optional_params)
    |> validate_required(@required_params)
  end

  def run(cards, %Card{} = card, %Rule{code: code}) do
    case Code.eval_string(code, card: card, cards: cards) do
      {true, _} ->
        :ok

      # TODO: error handle
      {false, _} ->
        {:error, ""}
    end
  end

  def insert!(attrs) when is_map(attrs) do
    %CardRule{}
    |> Map.merge(attrs)
    |> changeset
    |> Repo.insert!()
  end

  def insert!(list) when is_list(list), do: Enum.each(list, &insert!/1)
end
