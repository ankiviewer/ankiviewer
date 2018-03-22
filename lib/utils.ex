defmodule Utils do
  @doc """
  Ensures integer is the right size to be inserted into our psql database
  (for when milliseconds are given instead of seconds)
  iex>sanitize_integer(1234567890111)
  1234567890
  iex>sanitize_integer(123)
  123
  """
  def sanitize_integer(i) when is_integer(i) do
    if is_integer(i) and i |> Integer.digits() |> length > 10,
      do: i |> Kernel./(1000) |> trunc |> sanitize_integer,
      else: i
  end

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
