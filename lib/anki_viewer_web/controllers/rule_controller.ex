defmodule AnkiViewerWeb.RuleController do
  use AnkiViewerWeb, :controller

  def index(conn, _params) do
    json(conn, %{rules: Rule.all()})
  end

  def create(conn, %{"code" => code, "tests" => tests, "name" => name}) do
    case Rule.insert(%{code: code, tests: tests, name: name}) do
      {:ok, _rule} ->
        json(conn, %{err: false, params: Rule.all()})

      {:error, rule_errors} ->
        json(conn, %{err: true, params: rule_errors})
    end
  end

  def update(conn, %{"code" => code, "tests" => tests, "name" => name, "rid" => rid}) do
    case Rule.update(%{code: code, tests: tests, name: name, rid: String.to_integer(rid)}) do
      {:ok, _rule} ->
        json(conn, %{err: false, params: Rule.all()})

      {:error, rule_errors} ->
        json(conn, %{err: true, params: rule_errors})
    end
  end

  def delete(conn, %{"rid" => rid}) do
    Repo.delete!(%Rule{rid: String.to_integer(rid)})

    json(conn, %{rules: Rule.all()})
  end
end
