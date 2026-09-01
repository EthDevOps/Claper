defmodule Claper.Events.ReactionConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          emoji: String.t() | nil,
          weight: integer() | nil
        }

  @primary_key false
  @derive {Jason.Encoder, only: [:emoji, :weight]}
  embedded_schema do
    field :emoji, :string
    field :weight, :integer, default: 0
  end

  def changeset(reaction, attrs \\ %{}) do
    reaction
    |> cast(attrs, [:emoji, :weight])
    |> validate_required([:emoji, :weight])
    |> validate_length(:emoji, min: 1, max: 16)
    |> validate_inclusion(:weight, [-1, 0, 1])
  end
end
