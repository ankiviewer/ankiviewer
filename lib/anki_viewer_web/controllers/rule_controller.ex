defmodule AnkiViewerWeb.RuleController do
  use AnkiViewerWeb, :controller

  def index(conn, _params) do
    rules =
      Rule
      |> Repo.all()
      |> Utils.parseable_fields()

    json(conn, %{rules: rules})
  end

  def create(conn, %{"code" => code, "tests" => tests, "name" => name}) do
    %{code: code, tests: tests, name: name}
    |> Rule.validate()
    |> case do
      {:ok, rule} ->
        Rule.insert!(rule)

        params =
          Rule
          |> Repo.all()
          |> Utils.parseable_fields()

        json(conn, %{err: false, params: params})

      {:error, rule_errors} ->
        json(conn, %{err: true, params: rule_errors})
    end
  end

  def update(conn, %{"code" => code, "tests" => tests, "name" => name, "rid" => rid}) do
    %{code: code, tests: tests, name: name}
    |> Rule.validate()
    |> case do
      {:ok, rule} ->
        %Rule{rid: String.to_integer(rid)}
        |> Rule.changeset(rule)
        |> Repo.update!()

        params =
          Rule
          |> Repo.all()
          |> Utils.parseable_fields()

        json(conn, %{err: false, params: params})

      {:error, rule_errors} ->
        json(conn, %{err: true, params: rule_errors})
    end
  end

  def delete(conn, %{"rid" => rid}) do
    Repo.delete!(%Rule{rid: String.to_integer(rid)})

    params =
      Rule
      |> Repo.all()
      |> Utils.parseable_fields()

    json(conn, %{err: false, params: params})
  end
end
