defmodule Claper.Repo.Migrations.AddAnsweredToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :answered, :boolean, default: false, null: false
    end
  end
end
