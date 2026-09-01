defmodule Claper.Repo.Migrations.AddReactionsConfigAndCounts do
  use Ecto.Migration

  @default_reactions ~s([{"emoji":"👍","weight":1},{"emoji":"❤️","weight":1},{"emoji":"😂","weight":0}])

  def up do
    alter table(:events) do
      add :reactions, :map, default: @default_reactions
    end

    alter table(:posts) do
      add :reaction_counts, :map, default: "{}"
    end

    flush()

    execute("""
    UPDATE posts
    SET reaction_counts = jsonb_strip_nulls(
      jsonb_build_object(
        '👍', NULLIF(like_count, 0),
        '❤️', NULLIF(love_count, 0),
        '😂', NULLIF(lol_count, 0)
      )
    )
    """)

    alter table(:posts) do
      remove :like_count
      remove :love_count
      remove :lol_count
    end
  end

  def down do
    alter table(:posts) do
      add :like_count, :integer, default: 0
      add :love_count, :integer, default: 0
      add :lol_count, :integer, default: 0
    end

    flush()

    execute("""
    UPDATE posts
    SET
      like_count = COALESCE((reaction_counts->>'👍')::integer, 0),
      love_count = COALESCE((reaction_counts->>'❤️')::integer, 0),
      lol_count = COALESCE((reaction_counts->>'😂')::integer, 0)
    """)

    alter table(:posts) do
      remove :reaction_counts
    end

    alter table(:events) do
      remove :reactions
    end
  end
end
