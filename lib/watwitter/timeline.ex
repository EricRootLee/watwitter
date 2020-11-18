defmodule Watwitter.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false

  alias Watwitter.Accounts.User
  alias Watwitter.Repo
  alias Watwitter.Timeline.{Like, Post}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts(page: 1, per_page: 2)
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    from(p in Post,
      offset: ^((page - 1) * per_page),
      limit: ^per_page,
      order_by: [desc: p.id]
    )
    |> Repo.all()
    |> Repo.preload([:user, :likes])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Post |> Repo.get!(id) |> Repo.preload([:user, :likes])

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Likes a post.

  ## Examples

      iex> like_post(post, user)
      {:ok, %Like{}}

      iex> like_post(%{id: nil}, %{id: nil})
      {:error, %Ecto.Changeset{}}

  """
  def like_post(%Post{} = post, %User{} = user) do
    %Like{}
    |> Like.changeset(%{post_id: post.id, user_id: user.id})
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
