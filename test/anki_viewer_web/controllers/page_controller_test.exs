defmodule AnkiViewerWeb.PageControllerTest do
  use AnkiViewerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200)
  end

  describe "GET /collection" do
    test "with no collection data", %{conn: conn} do
      conn = get(conn, "/api/collection")

      assert json_response(conn, 200) == %{"last_modified_date" => 0, "number_notes" => 0}
    end

    test "with collection data", %{conn: conn} do
      load_collection!()
      conn = get(conn, "/api/collection")

      assert json_response(conn, 200) == %{
               "last_modified_date" => 1_514_655_628,
               "number_notes" => 10
             }
    end
  end
end
