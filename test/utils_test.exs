defmodule UtilsTest do
  use ExUnit.Case
  doctest Utils, import: true

  alias AnkiViewer.Card

  test "parseable fields" do
    input = [
      %{
        int: 1,
        str: "string",
        bool: true,
        map: %{},
        struct: %Card{cid: 123}
      },
      %{
        updated_at: ~N[2018-03-21 22:43:54.238796],
        __meta__: %Ecto.Schema.Metadata{},
        other_field: "other field",
        nested_map: %{
          key: %{
            ok_value: 1,
            date_value: ~N[2018-03-21 22:43:54.238796],
            struct: %Card{cid: 123}
          }
        }
      }
    ]

    actual = Utils.parseable_fields(input)

    expected_date = %{
      day: 21,
      hour: 22,
      minute: 43,
      month: 3,
      second: 54,
      year: 2018
    }

    expected = [
      %{
        int: 1,
        str: "string",
        bool: true,
        map: %{},
        struct: %{cid: 123, tags: []}
      },
      %{
        updated_at: expected_date,
        other_field: "other field",
        nested_map: %{
          key: %{
            ok_value: 1,
            struct: %{cid: 123, tags: []},
            date_value: expected_date
          }
        }
      }
    ]

    assert actual == expected
  end
end
