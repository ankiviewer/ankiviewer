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
end
