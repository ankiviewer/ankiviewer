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

  def validate(%{name: ""}), do: {:error, %{name: "Can't be blank"}}

  def validate(%{name: _, code: code, tests: tests} = rule) do
    case {validate(code), validate(tests)} do
      {{:error, code_error}, {:error, tests_error}} ->
        {:error, %{code: code_error, tests: tests_error}}

      {{:error, code_error}, :ok} ->
        {:error, %{code: code_error}}

      {:ok, {:error, tests_error}} ->
        {:error, %{tests: tests_error}}

      {:ok, :ok} ->
        {:ok, rule}
    end
  end

  @doc"""
  iex>Rule.validate("asdf()")
  {:error, "undefined function asdf/0"}
  iex>Rule.validate("1")
  :ok
  """
  def validate(code) when is_binary(code) do
    try do
      Code.eval_string(code, note: %Note{})

      :ok
    rescue
      error ->
        {:error, error.description}
    end
  end
end
