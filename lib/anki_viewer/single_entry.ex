defmodule AnkiViewer.SingleEntry do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias AnkiViewer.{Collection, Deck, Model, Repo}

      def insert_or_update!(struct, attrs \\ %{})

      def insert_or_update!(struct, attrs) when is_list(attrs) do
        if Repo.one(__MODULE__) do
          Repo.delete_all(__MODULE__)
        end

        for a <- attrs do
          struct
          |> changeset(a)
          |> Repo.insert!()
        end
      end

      def insert_or_update!(struct, attrs) do
        if Repo.one(__MODULE__) do
          Repo.delete_all(__MODULE__)
        end

        struct
        |> changeset(attrs)
        |> Repo.insert!()
      end

      defoverridable insert_or_update!: 1, insert_or_update!: 2
    end
  end
end
