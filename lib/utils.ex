defmodule Utils do
  @doc """
  Parses integer from binary when needed

  iex>sanitize_integer("1234567890111")
  1234567890111
  iex>sanitize_integer(123)
  123
  """
  def sanitize_integer(s) when is_binary(s) do
    case Integer.parse(s) do
      {i, ""} -> sanitize_integer(i)
      :error -> s
    end
  end

  def sanitize_integer(i), do: i

  def parseable_fields(map) when is_map(map) do
    map
    |> Map.drop([:__struct__, :__meta__])
    |> Enum.filter(fn {_k, v} ->
      ~w(is_integer is_binary is_boolean is_map is_list)a
      |> Enum.map(&apply(Kernel, &1, [v]))
      |> Enum.any?()
    end)
    |> Map.new(fn {k, v} ->
      cond do
        is_map(v) or is_list(v) -> {k, parseable_fields(v)}
        true -> {k, v}
      end
    end)
  end

  def parseable_fields(list) when is_list(list) do
    Enum.map(list, &parseable_fields/1)
  end
end
