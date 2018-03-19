defmodule AnkiViewer.TestHelpers do
  def configure_sqlite! do
    {"", 0} =
      System.cmd("sqlite3", [
        Application.get_env(:anki_viewer, :anki_db_path),
        ".read #{:code.priv_dir(:anki_viewer)}/anki_test_dump.sql"
      ])
  end
end
