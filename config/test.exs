use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :anki_viewer, AnkiViewerWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :anki_viewer, AnkiViewer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "anki_viewer_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
