defmodule Watwitter.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0

    has_many :replies, Watwitter.Timeline.Post, foreign_key: :reply_to_id
    has_many :likes, Watwitter.Timeline.Like
    belongs_to :reply_to, Watwitter.Timeline.Post
    belongs_to :user, Watwitter.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id, :reply_to_id])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, min: 2, max: 250)
  end
end
