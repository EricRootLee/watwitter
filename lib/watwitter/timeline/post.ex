defmodule Watwitter.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0

    belongs_to :user, Watwitter.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:user_id, :body])
    |> validate_required([:user_id, :body])
    |> validate_length(:body, min: 2, max: 250)
  end
end
