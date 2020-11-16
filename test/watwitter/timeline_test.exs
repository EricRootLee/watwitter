defmodule Watwitter.TimelineTest do
  use Watwitter.DataCase

  import Watwitter.Factory

  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post

  describe "list_posts/1" do
    test "list_posts/0 returns list of posts" do
      %{id: id, body: body} = insert(:post)
      assert [%{id: ^id, body: ^body}] = Timeline.list_posts()
    end

    test "list_posts/1 accepts pagination" do
      insert_list(3, :post)

      assert [_post1, _post2] = Timeline.list_posts(page: 1, per_page: 2)
      assert [_post3] = Timeline.list_posts(page: 2, per_page: 2)
    end
  end

  describe "get_post!/1" do
    test "get_post!/1 returns the post with given id" do
      %{id: id, body: body} = insert(:post)
      assert %Post{id: ^id, body: ^body} = Timeline.get_post!(id)
    end
  end

  describe "create_post/1" do
    test "create_post/1 with valid data creates a post" do
      user = insert(:user)
      valid_attrs = params_for(:post, user_id: user.id)
      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.body == valid_attrs.body
      assert post.likes_count == 0
      assert post.reposts_count == 0
      assert post.user_id == user.id
    end

    test "create_post/1 creates a reply when reply_to is set" do
      user = insert(:user)
      original_post = insert(:post)
      valid_attrs = params_for(:post, user_id: user.id, reply_to_id: original_post.id)
      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.reply_to_id == original_post.id
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(%{body: nil})
    end

    @two_hundred_and_fifty_one ~s"""
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut tortor pretium
      viverra suspendisse potenti nullam ac. Turpis egestas maecenas pharetra
      convallis posuere morbi leonur
    """
    test "create_post/1 must have a body between 2-250 characters" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(%{body: "a"})

      assert {:error, %Ecto.Changeset{}} =
               Timeline.create_post(%{body: @two_hundred_and_fifty_one})
    end

    test "broadcasts post created event" do
      Timeline.subscribe()
      %{body: body} = params = params_for(:post, user: insert(:user))

      {:ok, %{id: id}} = Timeline.create_post(params)

      assert_receive {:post_created, post}
      assert %{id: ^id, body: ^body} = post
    end
  end

  describe "inc_likes/1" do
    test "increments a post's likes count" do
      post = insert(:post, likes_count: 0)

      {:ok, _post} = Timeline.inc_likes(post)
      {:ok, updated_post} = Timeline.inc_likes(post)

      assert updated_post.likes_count == 2
    end

    test "broadcasts update to post" do
      Timeline.subscribe()
      %{id: id} = post = insert(:post, likes_count: 0)

      {:ok, _post} = Timeline.inc_likes(post)

      assert_receive {:post_updated, updated_post}
      assert %{id: ^id, likes_count: 1} = updated_post
    end
  end

  describe "inc_reposts/1" do
    test "increments a post's reposts count" do
      post = insert(:post, reposts_count: 0)

      {:ok, _post} = Timeline.inc_reposts(post)
      {:ok, updated_post} = Timeline.inc_reposts(post)

      assert updated_post.reposts_count == 2
    end

    test "broadcasts update to post" do
      Timeline.subscribe()
      %{id: id} = post = insert(:post, reposts_count: 0)

      {:ok, _post} = Timeline.inc_reposts(post)

      assert_receive {:post_updated, updated_post}
      assert %{id: ^id, reposts_count: 1} = updated_post
    end
  end

  describe "update_post/2" do
    test "update_post/2 with valid data updates the post" do
      post = insert(:post)
      update_attrs = %{body: "some updated body"}
      assert {:ok, %Post{} = post} = Timeline.update_post(post, update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = insert(:post)
      invalid_attrs = %{body: nil}
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, invalid_attrs)
      assert post.body == Timeline.get_post!(post.id).body
    end
  end

  describe "delete_post/1" do
    test "delete_post/1 deletes the post" do
      post = insert(:post)
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end
  end

  describe "change_post/1" do
    test "change_post/1 returns a post changeset" do
      post = insert(:post)
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end
end
