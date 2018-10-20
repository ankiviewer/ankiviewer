defmodule AnkiViewerWeb.PageControllerTest do
  use AnkiViewerWeb.ConnCase, async: false
  doctest AnkiViewerWeb.PageController, import: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200)
  end

  describe "GET /api/collection" do
    test "with no collection data", %{conn: conn} do
      conn = get(conn, "/api/collection")

      assert json_response(conn, 200) == %{
               "mod" => 0,
               "cards" => 0,
               "decks" => [],
               "models" => []
             }
    end

    test "with collection data", %{conn: conn} do
      load_collection!()
      conn = get(conn, "/api/collection")

      decks = [
        %{"did" => 1, "name" => "Default"},
        %{"did" => 1_482_060_876_072, "name" => "DE"},
        %{"did" => 1_503_955_755_113, "name" => "Thai"}
      ]

      models = [
        %{
          "did" => 1_482_060_876_072,
          "flds" => ["German", "English", "Hint"],
          "mid" => 1_482_842_770_192,
          "name" => "de_reverse"
        },
        %{
          "did" => 1_482_060_876_072,
          "flds" => ["German", "English", "Hint"],
          "mid" => 1_482_844_263_685,
          "name" => "de_en"
        },
        %{
          "did" => 1_482_060_876_072,
          "flds" => ["English", "German", "Hint"],
          "mid" => 1_482_844_395_181,
          "name" => "en_de"
        },
        %{
          "did" => 1_482_060_876_072,
          "flds" => ["Front", "Back"],
          "mid" => 1_498_897_408_555,
          "name" => "preposition_case"
        },
        %{"did" => 1, "flds" => ["Text", "Extra"], "mid" => 1_502_629_924_060, "name" => "Cloze"},
        %{
          "did" => 1,
          "flds" => ["Front", "Back"],
          "mid" => 1_507_832_105_615,
          "name" => "Basic (and reversed card)"
        }
      ]

      assert json_response(conn, 200) == %{
               "mod" => 1_514_655_628_599,
               "cards" => 10,
               "decks" => decks,
               "models" => models
             }
    end
  end

  describe "GET /api/cards" do
    test "with bad params", %{conn: conn} do
      conn = get(conn, "/api/cards")

      assert json_response(conn, 200) == %{"error" => "BAD PARAMS"}
    end

    test "without cards data", %{conn: conn} do
      params = ~s(search=&model=&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/cards?" <> params)

      assert json_response(conn, 200) == []
    end

    test "with cards data", %{conn: conn} do
      load_collection!()

      params = ~s(search=&model=&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/cards?" <> params)

      assert json_response(conn, 200) |> length == 10
    end

    test "with deck name", %{conn: conn} do
      load_collection!()

      params = ~s(search=&model=&deck=DE&tags=&modelorder=&rule=)

      conn = get(conn, "/api/cards?" <> params)

      assert json_response(conn, 200) |> length == 10
    end

    test "with model name", %{conn: conn} do
      load_collection!()

      params = ~s(search=&model=de_reverse&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/cards?" <> params)

      assert json_response(conn, 200) |> length == 10
    end

    test "with search", %{conn: conn} do
      load_collection!()

      cards = [
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
          "type" => 2,
          "front" => "Die Einigung",
          "back" => "the agreement",
          "mod" => 1_512_715_815,
          "ttype" => 2
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
          "type" => 2,
          "front" => "Die Einigung",
          "back" => "the agreement",
          "mod" => 1_512_715_815,
          "ttype" => 2
        }
      ]

      params = ~s(search=agreement&model=&deck=&tags=&modelorder=&rule=)

      conn = get(conn, "/api/cards?" <> params)

      assert json_response(conn, 200) == cards
    end
  end
end
