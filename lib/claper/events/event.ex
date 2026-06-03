defmodule Claper.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          uuid: Ecto.UUID.t(),
          name: String.t() | nil,
          code: String.t(),
          audience_peak: integer() | nil,
          started_at: NaiveDateTime.t(),
          expired_at: NaiveDateTime.t() | nil,
          reactions: [Claper.Events.ReactionConfig.t()] | nil,
          posts: [Claper.Posts.Post.t()] | nil,
          leaders: [Claper.Events.ActivityLeader.t()] | nil,
          presentation_file: Claper.Presentations.PresentationFile.t() | nil,
          user: Claper.Accounts.User.t() | nil,
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @max_reactions 6

  @default_reactions [
    %{emoji: "👍", weight: 1},
    %{emoji: "❤️", weight: 1},
    %{emoji: "😂", weight: 0}
  ]

  def max_reactions, do: @max_reactions
  def default_reactions, do: @default_reactions

  schema "events" do
    field :uuid, :binary_id
    field :name, :string
    field :code, :string
    field :audience_peak, :integer, default: 0
    field :started_at, :naive_datetime
    field :expired_at, :naive_datetime

    embeds_many :reactions, Claper.Events.ReactionConfig, on_replace: :delete

    has_many :posts, Claper.Posts.Post
    has_many :leaders, Claper.Events.ActivityLeader, on_replace: :delete

    has_one :presentation_file, Claper.Presentations.PresentationFile
    has_one :lti_resource, Lti13.Resources.Resource

    belongs_to :user, Claper.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :code,
      :started_at,
      :expired_at,
      :audience_peak,
      :user_id
    ])
    |> cast_embed(:reactions, with: &Claper.Events.ReactionConfig.changeset/2)
    |> cast_assoc(:presentation_file)
    |> cast_assoc(:leaders)
    |> validate_required([:name, :code, :started_at])
    |> validate_reactions()
  end

  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :code, :user_id, :started_at, :expired_at])
    |> cast_assoc(:presentation_file)
    |> cast_assoc(:leaders)
    |> downcase_code
    |> validate_required([:name, :code, :started_at, :user_id])
    |> validate_length(:code, min: 5, max: 10)
    |> validate_length(:name, min: 5, max: 50)
    |> put_change(:uuid, Ecto.UUID.generate())
    |> put_embed(
      :reactions,
      Enum.map(@default_reactions, &struct(Claper.Events.ReactionConfig, &1))
    )
  end

  def downcase_code(changeset) do
    case fetch_change(changeset, :code) do
      {:ok, nil} ->
        changeset

      {:ok, code} ->
        put_change(
          changeset,
          :code,
          code |> String.downcase() |> String.split(~r"[^\w\d]", trim: true) |> List.first()
        )

      :error ->
        changeset
    end
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :code, :started_at, :expired_at, :audience_peak, :user_id])
    |> cast_embed(:reactions, with: &Claper.Events.ReactionConfig.changeset/2)
    |> cast_assoc(:presentation_file)
    |> cast_assoc(:leaders)
    |> downcase_code
    |> validate_required([:name, :code, :started_at, :user_id])
    |> validate_length(:code, min: 5, max: 10)
    |> validate_length(:name, min: 5, max: 50)
    |> validate_reactions()
  end

  defp validate_reactions(changeset) do
    if get_change(changeset, :reactions) do
      reactions = get_field(changeset, :reactions) || []
      emojis = Enum.map(reactions, & &1.emoji)

      cond do
        length(reactions) > @max_reactions ->
          add_error(changeset, :reactions, "cannot exceed #{@max_reactions} reactions")

        length(emojis) != length(Enum.uniq(emojis)) ->
          add_error(changeset, :reactions, "reactions must be unique")

        true ->
          changeset
      end
    else
      changeset
    end
  end

  def restart_changeset(event) do
    expiry =
      NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.add(48 * 3600)

    change(event, expired_at: expiry)
  end

  def subscribe(event_uuid) do
    Phoenix.PubSub.subscribe(Claper.PubSub, "event:#{event_uuid}")
  end

  def started?(event) do
    NaiveDateTime.compare(NaiveDateTime.utc_now(), event.started_at) == :gt
  end

  def finished?(event) do
    event.expired_at && NaiveDateTime.compare(NaiveDateTime.utc_now(), event.expired_at) == :gt
  end
end
