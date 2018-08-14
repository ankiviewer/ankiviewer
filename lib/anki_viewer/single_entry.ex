defmodule AnkiViewer.SingleEntry do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias AnkiViewer.{Collection, Model, Deck, Repo, Note, NoteRule, Rule, Meta}

      def insert_or_update!(attrs) do
        if Repo.all(__MODULE__) != [] do
          Repo.delete_all(__MODULE__)
        end

        cond do
          is_list(attrs) ->
            for a <- attrs do
              __MODULE__
              |> struct()
              |> changeset(a)
              |> Repo.insert!()
            end

          Map.has_key?(attrs, :__struct__) ->
            attrs
            |> changeset()
            |> Repo.insert!()

          true ->
            __MODULE__ |> struct() |> Map.merge(attrs) |> insert_or_update!
        end
      end

      defoverridable insert_or_update!: 1
    end
  end
end
