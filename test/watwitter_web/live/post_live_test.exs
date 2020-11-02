defmodule WatwitterWeb.PostLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  describe "Index" do
    test "lists all posts", %{conn: conn} do
      post = create(:post)

      {:ok, _view, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Listing Posts"
      assert html =~ post.body
    end

    test "user can compose new tweet from timeline", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))

      view
      |> element("a", "New Post")
      |> render_click()

      assert has_element?(view, "#post-form")
    end

    test "user receives new tweets in timeline", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))
      first_post = %{username: "germsvel", body: "most excellent post"}
      second_post = %{username: "gandalf", body: "truly cool"}
      posts = [first_post, second_post]

      ensure_posts_absent(view, posts)

      Timeline.create_post(first_post)
      assert has_post(view, first_post)

      Timeline.create_post(second_post)
      assert has_post(view, second_post)
    end
  end

  defp has_post(view, post) do
    assert has_element?(view, "#posts", post.username)
    assert has_element?(view, "#posts", post.body)
  end

  defp ensure_posts_absent(view, posts) do
    Enum.each(posts, fn post ->
      refute has_element?(view, "#posts", post.username)
      refute has_element?(view, "#posts", post.body)
    end)
  end

  defp create(:post) do
    attrs = %{username: "germsvel", body: "some body"}

    {:ok, post} = Timeline.create_post(attrs)
    post
  end
end
