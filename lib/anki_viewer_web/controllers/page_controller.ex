defmodule AnkiViewerWeb.PageController do
  use AnkiViewerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def collection(conn, _params) do
    case Repo.one(Collection) do
      nil ->
        json(conn, %{mod: 0, notes: 0})

      %{mod: mod} ->
        notes = Note |> Repo.all() |> length()
        json(conn, %{mod: mod, notes: notes})
    end
  end
end
