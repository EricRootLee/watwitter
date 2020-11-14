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

  test "users receive new posts in timeline", %{conn: conn} do
    another_user = insert(:user)
    post_params = params_for(:post, user: another_user)

    {:ok, view, _html} = conn |> log_in_user() |> live("/")

    Timeline.create_post(post_params)

    render(view)

    assert has_element?(view, ".post", another_user.username)
    assert has_element?(view, ".post", post_params.body)
  end

  test "user can like a post", %{conn: conn} do
    post = insert(:post, likes_count: 0)
    {:ok, view, _html} = conn |> log_in_user() |> live("/")

    view
    |> element(post_like_button(post))
    |> render_click()

    assert has_element?(view, post_like_count(post), "1")
  end

  defp compose_button, do: "[data-role='compose']"
  defp post_like_button(post), do: post_card(post) <> " [data-role='like-button']"
  defp post_like_count(post), do: post_card(post) <> " [data-role='like-count']"
  defp post_card(post), do: "#post-#{post.id}"
end
