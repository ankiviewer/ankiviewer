defmodule AnkiViewer.NoteRule do
  use Ecto.Schema
  import Ecto.Changeset
  alias AnkiViewer.{Note, Rule, NoteRule, Repo}

  schema "note_rules" do
    field(:comment, :string)
    field(:fails, :boolean, default: false)
    field(:ignore, :boolean, default: false)
    field(:nid, :integer)
    field(:rid, :integer)
    field(:solution, :string)
    field(:url, :string)

    timestamps()
  end

  @required_params ~w(fails nid rid)a
  @optional_params ~w(comment solution url ignore)a
  def changeset(%NoteRule{} = note_rule, attrs \\ %{}) do
    note_rule
    |> cast(attrs, @required_params ++ @optional_params)
    |> validate_required(@required_params)
  end

  def run(notes, %Note{} = note, %Rule{code: code}) do
    rule_func = """
    const ruleFunc = #{code};
    const notes = process.argv[1];
    const note = process.argv[2];
    JSON.parse(notes).forEach((note) => {
      if (!ruleFunc(notes, note)) {
        process.exit(1);
      }
    });
    """

    [notes, note] =
      [notes, note] |> Enum.map(&(&1 |> Utils.parseable_fields() |> Jason.encode!()))

    case System.cmd("node", ["-e", rule_func, notes, note]) do
      {"", 0} -> :ok
      {error, 1} -> {:error, error}
    end
  end

  def insert!(attrs) when is_map(attrs) do
    attrs
    |> Map.has_key?(:__struct__)
    |> case do
      true -> attrs
      false -> Map.merge(%NoteRule{}, attrs)
    end
    |> changeset
    |> Repo.insert!()
  end

  def insert!(list) when is_list(list), do: list |> Enum.each(&insert!/1)
end
