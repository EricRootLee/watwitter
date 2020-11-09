defmodule Watwitter.TimelineTest do
  use Watwitter.DataCase

  import Watwitter.Factory

  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post

  describe "posts" do
    test "list_posts/0 returns posts" do
      post = insert(:post)

      [found_post] = Timeline.list_posts()

      assert found_post.id == post.id
      assert found_post.body == post.body
      assert found_post.user.username == post.user.username
    end

    test "get_post!/1 returns the post with given id" do
      post = insert(:post)

      found_post = Timeline.get_post!(post.id)
      assert found_post.id == post.id
      assert found_post.body == post.body
    end

    test "create_post/1 with valid data creates a post" do
      user = insert(:user)
      params = string_params_for(:post) |> Map.put("user_id", user.id)
      assert {:ok, %Post{} = post} = Timeline.create_post(params)
      assert post.body == params["body"]
      assert post.user_id == user.id
    end

    test "create_post/1 with invalid data returns error changeset" do
      invalid_attrs = params_for(:post, body: nil)
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = insert(:post, body: "hello world")
      params = %{"body" => "super hello world"}
      assert {:ok, %Post{} = post} = Timeline.update_post(post, params)
      assert post.body == "super hello world"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = insert(:post)
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, %{"body" => nil})
      assert post.body == Timeline.get_post!(post.id).body
    end

    test "delete_post/1 deletes the post" do
      post = insert(:post)
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = insert(:post)
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end
end
