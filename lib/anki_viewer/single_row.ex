defmodule AnkiViewer.SingleRow do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias AnkiViewer.{Collection, Deck, Model, Repo}

      def insert_or_update!(struct, attrs \\ %{}) do
        case Repo.one(__MODULE__) do
          nil ->
            nil
          _ ->
            Repo.delete_all __MODULE__
        end
        struct
        |> changeset(attrs)
        |> Repo.insert!
      end

      defoverridable insert_or_update!: 1, insert_or_update!: 2
    end

  end
end
