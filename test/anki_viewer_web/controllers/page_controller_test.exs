defmodule AnkiViewerWeb.PageControllerTest do
  use AnkiViewerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200)
  end

  describe "GET /api/collection" do
    test "with no collection data", %{conn: conn} do
      conn = get(conn, "/api/collection")

      assert json_response(conn, 200) == %{"mod" => 0, "notes" => 0}
    end

    test "with collection data", %{conn: conn} do
      load_collection!()
      conn = get(conn, "/api/collection")

      assert json_response(conn, 200) == %{"mod" => 1_514_655_628, "notes" => 10}
    end
  end

  describe "GET /api/notes" do
    test "with bad params", %{conn: conn} do
      conn = get(conn, "/api/notes")

      assert json_response(conn, 200) == %{"error" => "BAD PARAMS"}
    end

    test "without notes data", %{conn: conn} do
      params =  ~s(search=&model=&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/notes?" <> params)

      assert json_response(conn, 200) == []
    end

    test "with notes data", %{conn: conn} do
      load_collection!()

      params = ~s(search=&model=&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/notes?" <> params)

      assert json_response(conn, 200) |> length == 10
    end

    test "with deck name", %{conn: conn} do
      load_collection!()

      params = ~s(search=&model=&deck=DE&tags=&modelorder=&rule=)

      conn = get(conn, "/api/notes?" <> params)

      assert json_response(conn, 200) |> length == 10
    end

    test "with search", %{conn: conn} do
      load_collection!()

      notes = [
        %{
          "deck" => "DE",
          "due" => 415,
          "flds" => "Die Einigungthe agreement",
          "lapses" => 0,
          "model" => "de_reverse",
          "ord" => 0,
          "queue" => 2,
          "reps" => 3,
          "sfld" => "the agreement",
          "tags" => [],
          "type" => 2
        },
        %{
          "deck" => "DE",
          "due" => 395,
          "flds" => "Die Einigungthe agreement",
          "lapses" => 2,
          "model" => "de_reverse",
          "ord" => 1,
          "queue" => 2,
          "reps" => 10,
          "sfld" => "the agreement",
          "tags" => [],
          "type" => 2
        }
      ]

      params = ~s(search=agreement&model=&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/notes?" <> params)

      assert json_response(conn, 200) == notes
    end
  end
end
