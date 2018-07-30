defmodule AnkiViewer.Rule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.{Rule, Repo, Note}

  @primary_key {:rid, :id, autogenerate: true}
  schema "rules" do
    field(:code, :string)
    field(:tests, :string)
    field(:name, :string)

    timestamps()
  end

  @optional_attrs ~w(rid)a
  @required_attrs ~w(code name tests)a
  def changeset(%Rule{} = rule, attrs \\ %{}) do
    rule
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_length(:name, min: 1, max: 30)
    |> validate_change(:code, rule_validator_helper(:code))
    |> validate_change(:tests, rule_validator_helper(:tests))
  end

  defp rule_validator_helper(atom) when is_atom(atom) do
    fn atom, str ->
      case validate(str) do
        :ok ->
          []

        {:error, str_error} ->
          [{atom, str_error}]
      end
    end
  end

  defp insert_update_helper(attrs, repo_func) do
    case changeset = changeset(%Rule{rid: Map.get(attrs, :rid)}, attrs) do
      %Ecto.Changeset{valid?: true} ->
        repo_func.(changeset)

      %Ecto.Changeset{errors: errors} ->
        {:error, errors |> Map.new(fn {k, {msg, _}} -> {k, msg} end)}
    end
  end

  def insert(attrs) when is_map(attrs), do: insert_update_helper(attrs, &Repo.insert/1)

  def insert(list) when is_list(list), do: Enum.each(list, &insert/1)

  def insert!(attrs) when is_map(attrs) do
    case insert(attrs) do
      {:ok, struct} ->
        struct

      {:error, insert_error} ->
        raise Ecto.QueryError, Enum.map(insert_error, fn k, v -> "#{k}: #{v}" end)
    end
  end

  def insert!(list) when is_list(list), do: Enum.each(list, &insert!/1)

  def update(%{rid: _rid} = attrs), do: insert_update_helper(attrs, &Repo.update/1)

  def all, do: Rule |> Repo.all() |> Utils.parseable_fields()

  defp status(bool), do: if(bool, do: "ok", else: "not ok")

  def run_tests(%Rule{} = rule) do
    {tests, []} = Code.eval_string(rule.tests)

    Enum.find(tests, :ok, fn %{fine: fine, note: note, deck: deck} ->
      {eval_fine, _} = Code.eval_string(rule.code, note: note, deck: deck)
      eval_fine != fine
    end)
    |> case do
      :ok ->
        :ok

      %{fine: fine, note: note, deck: deck} ->
        {:error,
         "note: #{inspect(note)} and deck: #{inspect(deck)} were expected to be #{status(fine)}, but were actually #{
           status(not fine)
         } for rule: #{rule.name}"}
    end
  end

  @doc """
  iex>validate("asdf()")
  {:error, "undefined function asdf/0"}
  iex>validate("1")
  :ok
  """
  def validate(code) when is_binary(code) do
    try do
      # TODO create more thorough note
      note = %Note{
        sfld: ""
      }

      Code.eval_string(code, note: note, deck: [note])

      :ok
    rescue
      error ->
        {:error, error.description}
    end
  end
end
