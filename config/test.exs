use Mix.Config

config :anki_viewer, AnkiViewerWeb.Endpoint,
  http: [port: 5001],
  server: true

config :anki_viewer, anki_db_path: "#{System.get_env("TMP_DIR") || "/tmp"}/anki_test.db"

config :logger, level: :warn

config :anki_viewer, AnkiViewer.Repo,
  username: "postgres",
  password: "postgres",
  database: "anki_viewer_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 10 * 60 * 1000
