defmodule AnkiViewerWeb.PageController do
  use AnkiViewerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def collection(conn, _params) do
    [last_modified_date, number_notes] =
      case Collection |> Repo.one() do
        nil ->
          [0, 0]

        c ->
          [
            c.mod,
            Note |> Repo.all() |> length
          ]
      end

    attrs = %{
      last_modified_date: last_modified_date,
      number_notes: number_notes
    }

    json(conn, attrs)
  end
end
