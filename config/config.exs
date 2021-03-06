# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :anki_viewer,
  ecto_repos: [AnkiViewer.Repo],
  anki_db_path: System.get_env("ANKI_DB_PATH")

# Configures the endpoint
config :anki_viewer, AnkiViewerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Z7/urn31WtUJZWm56YFBW6V3OyqqxAPvTdyoBqI+wk7mvtI1qxER3fNu7poP55dM",
  render_errors: [view: AnkiViewerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AnkiViewer.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
