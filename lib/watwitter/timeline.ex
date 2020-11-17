defmodule Watwitter.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
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
    |> Repo.preload([:user, :likes, [reply_to: :user]])
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
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload([:user, :likes, replies: [:likes, :user]])
  end

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
    |> broadcast(:post_created)
  end

  def like_post(user, post) do
    {:ok, %{post: post}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:likes, Like.changeset(%Like{}, %{user_id: user.id, post_id: post.id}))
      |> Ecto.Multi.run(:post, fn _, _ -> inc_likes(post) end)
      |> Repo.transaction()

    broadcast({:ok, post}, :post_updated)
  end

  defp inc_likes(%Post{id: id}) do
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [likes_count: 1])

    {:ok, post}
  end

  def inc_reposts(%Post{id: id}) do
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [reposts_count: 1])

    broadcast({:ok, post}, :post_updated)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
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

  def subscribe do
    Phoenix.PubSub.subscribe(Watwitter.PubSub, "posts")
  end

  defp broadcast({:error, _} = error, _event), do: error

  defp broadcast({:ok, post}, event) do
    post = Repo.preload(post, [:user, :likes])
    Phoenix.PubSub.broadcast(Watwitter.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
