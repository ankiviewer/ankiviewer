defmodule AnkiViewer.SingleEntry do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias AnkiViewer.{Collection, Model, Deck, Repo, Card, CardRule, Rule}

      def insert_or_update!(attrs) do
        if Repo.all(__MODULE__) != [] do
          Repo.delete_all(__MODULE__)
        end

        if is_list(attrs) do
          for a <- attrs do
            __MODULE__
            |> struct()
            |> changeset(a)
            |> Repo.insert!()
          end
        else
          __MODULE__
          |> struct()
          |> Map.merge(attrs)
          |> changeset()
          |> Repo.insert!()
        end
      end

      defoverridable insert_or_update!: 1
    end
  end
end
