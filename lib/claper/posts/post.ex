defmodule Claper.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          body: String.t(),
          uuid: Ecto.UUID.t(),
          reaction_counts: %{optional(String.t()) => integer()} | nil,
          name: String.t() | nil,
          attendee_identifier: String.t() | nil,
          position: integer() | nil,
          pinned: boolean() | nil,
          answered: boolean() | nil,
          event_id: integer() | nil,
          user_id: integer() | nil,
          reactions: [Claper.Posts.Reaction.t()] | nil,
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "posts" do
    field :body, :string
    field :uuid, :binary_id
    field :reaction_counts, :map, default: %{}
    field :name, :string
    field :attendee_identifier, :string
    field :position, :integer, default: 0
    field :pinned, :boolean, default: false
    field :answered, :boolean, default: false

    belongs_to :event, Claper.Events.Event
    belongs_to :user, Claper.Accounts.User
    has_many :reactions, Claper.Posts.Reaction

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :body,
      :attendee_identifier,
      :user_id,
      :reaction_counts,
      :name,
      :position,
      :pinned,
      :answered
    ])
    |> validate_required([:body, :position])
    |> validate_length(:body, min: 2, max: 255)
  end

  def nickname_changeset(post, attrs) do
    post
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 20)
  end

  @doc """
  Returns the count for a specific emoji on this post.
  """
  def reaction_count(%__MODULE__{reaction_counts: counts}, emoji) when is_map(counts) do
    Map.get(counts, emoji, 0)
  end

  def reaction_count(_post, _emoji), do: 0

  @doc """
  Computes the post's popularity as the sum of (count × weight) across the
  event's configured reactions. Emojis no longer in the config are ignored.
  """
  def popularity(%__MODULE__{reaction_counts: counts}, reactions_config) when is_map(counts) do
    Enum.reduce(reactions_config, 0, fn %{emoji: emoji, weight: weight}, acc ->
      acc + Map.get(counts, emoji, 0) * weight
    end)
  end

  def popularity(_post, _config), do: 0
end
