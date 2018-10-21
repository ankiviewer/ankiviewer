defmodule AnkiViewerWeb.Router do
  use AnkiViewerWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AnkiViewerWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/:route", PageController, :index)
  end

  scope "/api", AnkiViewerWeb do
    pipe_through(:api)

    get("/collection", PageController, :collection)
    get("/cards", PageController, :cards)

    get("/rules", RuleController, :index)
    post("/rules", RuleController, :create)
    put("/rules/:rid", RuleController, :update)
    delete("/rules/:rid", RuleController, :delete)
  end
end
