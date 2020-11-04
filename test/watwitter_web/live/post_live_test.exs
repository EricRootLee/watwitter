defmodule WatwitterWeb.PostLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  describe "Index" do
    test "lists posts", %{conn: conn} do
      post = create(:post)

      {:ok, _view, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Home"
      assert html =~ post.body
    end

    test "user can compose new tweet from timeline", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))

      view
      |> element("a")
      |> render_click()

      assert has_element?(view, "#post-form")
    end

    test "user receives notice of new tweets in timeline", %{conn: conn} do
      create_list(:post, 5)
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))
      first_post = %{username: "aragorn", body: "most excellent post"}
      second_post = %{username: "gandalf", body: "truly cool"}
      posts = [first_post, second_post]

      ensure_posts_absent(view, posts)

      Timeline.create_post(first_post)
      assert has_element?(view, "#new-posts-notice", "1")

      Timeline.create_post(second_post)
      assert has_element?(view, "#new-posts-notice", "2")

      view
      |> element("#new-posts-notice", "Show 2 posts")
      |> render_click()

      assert_has_new_post(view, first_post)
      assert_has_new_post(view, second_post)
      assert page_title(view) =~ "Home"
    end

    test "page title reflects number of new tweets", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))
      first_post = %{username: "aragorn", body: "most excellent post"}
      second_post = %{username: "gandalf", body: "truly cool"}

      Timeline.create_post(first_post)
      Timeline.create_post(second_post)

      render(view)

      assert page_title(view) =~ "(2) Home"
    end

    test "load more hook fetches more posts (10 per page)", %{conn: conn} do
      [first, second | _] = create_list(:post, 12)
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))

      view
      |> element("#load-more")
      |> render_hook("load-more")

      assert has_element?(view, post_card(second), second.username)
      assert has_element?(view, post_card(second), second.body)
      assert has_element?(view, post_card(first), first.username)
      assert has_element?(view, post_card(first), first.body)
    end
  end

  defp post_card(post) do
    "#post-#{post.id}"
  end

  defp assert_has_new_post(view, post) do
    assert has_element?(view, "#new-posts", post.username)
    assert has_element?(view, "#new-posts", post.body)
  end

  defp ensure_posts_absent(view, posts) do
    Enum.each(posts, fn post ->
      refute has_element?(view, "#posts", post.username)
      refute has_element?(view, "#posts", post.body)
    end)
  end

  defp create_list(:post, count) do
    1..count
    |> Enum.map(fn i ->
      create(:post, %{username: "germsvel#{i}", body: "This is watweet #{i}"})
    end)
  end

  @default_attrs %{username: "germsvel", body: "some body"}
  defp create(:post, attrs \\ @default_attrs) do
    {:ok, post} = Timeline.create_post(attrs)
    post
  end
end
