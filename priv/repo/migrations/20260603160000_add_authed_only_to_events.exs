defmodule Claper.Repo.Migrations.AddAuthedOnlyToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :authed_only, :boolean, default: false, null: false
    end
  end
end
