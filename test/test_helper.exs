ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(AnkiViewer.Repo, :manual)

tmp = System.get_env("TMP_DIR") || "/tmp"

{"", 0} =
  System.cmd("sqlite3", [
    "#{tmp}/anki_test.db",
    ".read #{:code.priv_dir(:anki_viewer)}/anki_test_dump.sql"
  ])
