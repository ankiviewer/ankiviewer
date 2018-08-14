defmodule AnkiViewer.Meta do
  use AnkiViewer.SingleEntry

  @primary_key false
  schema "meta" do
    field(:last_update_time, :integer)
  end

  @attrs ~w(last_update_time)a
  def changeset(%Meta{} = meta, attrs \\ %{}) do
    meta
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end
end
