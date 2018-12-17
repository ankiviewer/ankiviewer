defmodule AnkiViewerWeb.RuleController do
  use AnkiViewerWeb, :controller

  defp rule_all() do
    Rule.all()
    |> Enum.map(fn rule ->
      run =
        CardRule
        |> where([cr], cr.rid == ^rule.rid)
        |> Repo.all()
        |> length()
        |> Kernel.==(Card |> where([c], c.did in ^rule.dids) |> Repo.all() |> length())

      Map.merge(rule, %{run: run})
    end)
  end

  def index(conn, _params) do
    json(conn, %{rules: rule_all()})
  end

  def create(conn, %{"code" => code, "tests" => tests, "name" => name, "dids" => dids}) do
    case Rule.insert(%{code: code, tests: tests, name: name, dids: dids}) do
      {:ok, _rule} ->
        json(conn, %{err: false, params: rule_all()})

      {:error, rule_errors} ->
        json(conn, %{err: true, params: rule_errors})
    end
  end

  def update(conn, %{
        "code" => code,
        "tests" => tests,
        "name" => name,
        "rid" => rid,
        "dids" => dids
      }) do
    case Rule.update(%{
           code: code,
           tests: tests,
           name: name,
           rid: String.to_integer(rid),
           dids: dids
         }) do
      {:ok, _rule} ->
        CardRule
        |> where([cr], cr.rid == ^rid)
        |> Repo.delete_all()

        json(conn, %{err: false, params: rule_all()})

      {:error, rule_errors} ->
        json(conn, %{err: true, params: rule_errors})
    end
  end

  def delete(conn, %{"rid" => rid}) do
    Repo.delete!(%Rule{rid: String.to_integer(rid)})

    CardRule
    |> where([cr], cr.rid == ^rid)
    |> Repo.delete_all()

    json(conn, %{rules: rule_all()})
  end
end
