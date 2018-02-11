defmodule AnkiViewerWeb.PageController do
  use AnkiViewerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
