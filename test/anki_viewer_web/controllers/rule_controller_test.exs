defmodule AnkiViewerWeb.RuleControllerTest do
  use AnkiViewerWeb.ConnCase, async: false
  doctest AnkiViewerWeb.PageController, import: true

  @code """
    note.sfld != ""
  """
  @tests """
    [
      %{
        note: %{sfld: "h"},
        fine: true,
        deck: nil
      },
      %{
        note: %{sfld: ""},
        fine: false,
        deck: nil
      }
    ]
  """
  @name "no blank fields"

  test "GET /api/rules", %{conn: conn} do
    conn = get(conn, "/api/rules")

    assert json_response(conn, 200) == %{"rules" => []}

    %Rule{name: @name, code: @code, tests: @tests}
    |> Repo.insert!()

    conn = get(conn, "/api/rules")

    %{"rules" => rules} = json_response(conn, 200)

    assert Enum.all?(rules, fn r ->
             ~w(inserted_at updated_at rid) |> Enum.all?(&(&1 in Map.keys(r)))
           end)

    actual = Enum.map(rules, &Map.drop(&1, ~w(inserted_at updated_at rid)))

    expected = [
      %{"name" => @name, "code" => @code, "tests" => @tests}
    ]

    assert actual == expected
  end

  describe "POST /api/rules" do
    test "valid params", %{conn: conn} do
      params = %{"code" => @code, "name" => @name, "tests" => @tests}
      conn = post(conn, "/api/rules", params)

      %{"err" => false, "params" => actual} = json_response(conn, 200)
      [%{"rid" => rid}] = actual

      assert actual |> List.first() |> Map.take(~w(code name tests)) == params

      actual =
        Rule
        |> Repo.all()
        |> Utils.parseable_fields()
        |> Enum.map(&Map.drop(&1, ~w(inserted_at updated_at)a))

      expected = [%{code: @code, name: @name, tests: @tests, rid: rid}]

      assert actual == expected
    end

    test "invalid params", %{conn: conn} do
      code = """
        note.sfld != "
      """

      params = %{"code" => code, "name" => @name, "tests" => @tests}
      conn = post(conn, "/api/rules", params)

      %{"err" => true, "params" => actual} = json_response(conn, 200)
      %{"code" => code_error} = actual

      assert code_error == "missing terminator: \" (for string starting at line 1)"

      assert Repo.one(Rule) == nil
    end
  end

  describe "PUT /api/rules/:rid" do
    test "valid params", %{conn: conn} do
      params = %{"name" => @name, "code" => @code, "tests" => @tests}

      %{rid: rid} = Repo.insert!(%Rule{name: @name, code: @code, tests: @tests})

      new_params = %{params | "name" => "new name"}

      conn = put(conn, "/api/rules/#{rid}", new_params)

      %{"err" => false, "params" => params} = json_response(conn, 200)
      [%{"rid" => ^rid}] = params

      assert params |> List.first() |> Map.take(~w(code name tests)) == new_params

      %{name: name, code: code, tests: tests} = Repo.one(Rule)

      assert %{"name" => name, "code" => code, "tests" => tests} == new_params
    end

    test "invalid params", %{conn: conn} do
      code = """
        note.sfld != "
      """

      params = %{"name" => @name, "code" => @code, "tests" => @tests}

      %{rid: rid} = Repo.insert!(%Rule{name: @name, code: @code, tests: @tests})

      new_params = %{params | "name" => "new name", "code" => code}

      conn = put(conn, "/api/rules/#{rid}", new_params)

      %{"err" => true, "params" => %{"code" => code_error}} = json_response(conn, 200)

      assert code_error == "missing terminator: \" (for string starting at line 1)"

      %{name: name, code: code, tests: tests} = Repo.one(Rule)

      assert %{"name" => name, "code" => code, "tests" => tests} == params
    end
  end

  test "DELETE /api/rules/:rid", %{conn: conn} do
    params = %{name: @name, code: @code, tests: @tests}

    %{rid: rid} =
      %Rule{}
      |> Map.merge(params)
      |> Repo.insert!()

    assert Repo.one(Rule) != nil

    conn = delete(conn, "/api/rules/#{rid}")

    assert json_response(conn, 200) == %{"err" => false, "params" => []}

    assert Repo.one(Rule) == nil
  end
end
