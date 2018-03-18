ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(AnkiViewer.Repo, :manual)

{"", 0} =
  System.cmd("sqlite3", [
    Application.get_env(:anki_viewer, :anki_db_path),
    ".read #{:code.priv_dir(:anki_viewer)}/anki_test_dump.sql"
  ])
