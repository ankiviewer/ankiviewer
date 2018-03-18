use Mix.Config

config :anki_viewer, AnkiViewerWeb.Endpoint,
  http: [port: 4001],
  server: true

config :anki_viewer, anki_db_path: "#{System.get_env("TMP_DIR") || "/tmp"}/anki_test.db"

config :logger, level: :warn

config :anki_viewer, AnkiViewer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "anki_viewer_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  #  10 mins
  ownership_timeout: 10 * 60 * 60
