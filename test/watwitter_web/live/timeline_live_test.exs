defmodule WatwitterWeb.Live.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias Watwitter.Timeline

  test "redirects to login page if unauthenticated", %{conn: conn} do
    {:error, {:redirect, %{to: path}}} = live(conn, "/")

    assert path == Routes.user_session_path(conn, :new)
  end

  test "renders the Home page", %{conn: conn} do
    {:ok, view, html} = conn |> log_in_user() |> live("/")

    assert html =~ "Home"
    assert render(view) =~ "Home"
  end

  test "renders a list of posts", %{conn: conn} do
    [post1, post2] = insert_pair(:post)

    {:ok, view, _html} = conn |> log_in_user() |> live("/")

    render(view)

    assert has_element?(view, post_card(post1), post1.body)
    assert has_element?(view, post_card(post2), post2.body)
  end

  test "user can open compose post", %{conn: conn} do
    conn = log_in_user(conn)
    {:ok, view, _html} = live(conn, "/")

    {:ok, compose_view, _html} =
      view
      |> element(compose_button())
      |> render_click()
      |> follow_redirect(conn, Routes.post_path(conn, :new))

    {:ok, timeline_view, _html} =
      compose_view
      |> form("#new-post", post: %{body: "This is the best watweet"})
      |> render_submit()
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert has_element?(timeline_view, ".post", "This is the best watweet")
  end

  test "users receive new posts notice in timeline and tab title", %{conn: conn} do
    another_user = insert(:user)
    post_params = params_for(:post, user: another_user)

    {:ok, view, _html} = conn |> log_in_user() |> live("/")

    Timeline.create_post(post_params)
    Timeline.create_post(post_params)

    render(view)

    assert has_element?(view, new_posts_notice(), "2")
    assert page_title(view) =~ "2"
  end

  test "users can see new posts when clicking new posts notice", %{conn: conn} do
    another_user = insert(:user)
    post_params = params_for(:post, user: another_user)

    {:ok, view, _html} = conn |> log_in_user() |> live("/")

    {:ok, post} = Timeline.create_post(post_params)

    view
    |> element(new_posts_notice(), "1")
    |> render_click()

    assert has_element?(view, post_card(post), post.body)
  end

  test "user can like a post", %{conn: conn} do
    post = insert(:post, likes_count: 0)
    {:ok, view, _html} = conn |> log_in_user() |> live("/")

    view
    |> element(post_like_button(post))
    |> render_click()

    assert has_element?(view, post_like_count(post), "1")
  end

  test "user can repost a post", %{conn: conn} do
    post = insert(:post, reposts_count: 0)
    user = insert(:user)
    {:ok, view, _html} = conn |> log_in_user(user) |> live("/")

    view
    |> element(post_repost_button(post))
    |> render_click()

    assert has_element?(view, post_repost_count(post), "1")
  end

  test "user can reply to a post", %{conn: conn} do
    post = insert(:post)
    user = insert(:user)
    conn = conn |> log_in_user(user)
    {:ok, view, _html} = live(conn, "/")

    {:ok, post_view, _html} =
      view
      |> element(post_reply_button(post))
      |> render_click()
      |> follow_redirect(conn, Routes.post_path(conn, :new, reply_to: post.id))

    {:ok, timeline_view, _html} =
      post_view
      |> form("#new-post", post: %{body: "That was great"})
      |> render_submit()
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert has_element?(timeline_view, ".reply-notice", replying_notice(post.user))
    assert has_element?(timeline_view, ".post", "That was great")
  end

  test "user can see a post with all replies", %{conn: conn} do
    post = insert(:post)
    [reply1, reply2] = insert_pair(:post, reply_to_id: post.id)
    conn = conn |> log_in_user()
    {:ok, view, _html} = live(conn, "/")

    {:ok, _post_view, html} =
      view
      |> element("a", post.body)
      |> render_click()
      |> follow_redirect(conn, Routes.post_show_path(conn, :show, post.id))

    assert html =~ reply1.body
    assert html =~ reply2.body
  end

  defp replying_notice(user) do
    "Replying to @#{user.username}"
  end

  defp new_posts_notice, do: "[data-role='new-posts-notice']"
  defp compose_button, do: "[data-role='compose']"
  defp post_like_button(post), do: post_card(post) <> " [data-role='like-button']"
  defp post_like_count(post), do: post_card(post) <> " [data-role='like-count']"
  defp post_repost_button(post), do: post_card(post) <> " [data-role='repost-button']"
  defp post_repost_count(post), do: post_card(post) <> " [data-role='repost-count']"
  defp post_reply_button(post), do: post_card(post) <> " [data-role='reply-button']"
  defp post_card(post), do: "#post-#{post.id}"
end
