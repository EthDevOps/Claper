defmodule Claper.Repo.Migrations.AddTreatAllAsQuestionsToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :treat_all_as_questions, :boolean, default: false, null: false
    end
  end
end
