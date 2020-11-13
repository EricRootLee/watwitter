defmodule WatwitterWeb.Live.PostLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  test "redirects to log in when unauthenticated", %{conn: conn} do
    {:error, {:redirect, %{to: path}}} = live(conn, Routes.post_path(conn, :new))

    assert path == Routes.user_session_path(conn, :new)
  end

  test "renders compose view with avatar", %{conn: conn} do
    user = insert(:user)
    conn = log_in_user(conn, user)
    {:ok, _view, html} = live(conn, Routes.post_path(conn, :new))

    assert html =~ "Compose Watweet"
    assert html =~ user.avatar_url
  end

  test "user can create new post", %{conn: conn} do
    conn = log_in_user(conn)
    {:ok, view, _html} = live(conn, Routes.post_path(conn, :new))

    {:ok, _, html} =
      view
      |> form("#new-post", post: %{body: "This is the best"})
      |> render_submit()
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert html =~ "This is the best"
  end

  @two_hundred_and_fifty_one ~s"""
  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut tortor pretium
    viverra suspendisse potenti nullam ac. Turpis egestas maecenas pharetra
    convallis posuere morbi leonur
  """
  test "cannot create post with more than 250 characters", %{conn: conn} do
    conn = log_in_user(conn)
    {:ok, view, _html} = live(conn, Routes.post_path(conn, :new))

    rendered =
      view
      |> form("#new-post", post: %{body: @two_hundred_and_fifty_one})
      |> render_change()

    assert rendered =~ "should be at most 250 character(s)"
  end

  test "cannot submit empty post", %{conn: conn} do
    conn = log_in_user(conn)
    {:ok, view, _html} = live(conn, Routes.post_path(conn, :new))

    rendered =
      view
      |> form("#new-post", post: %{body: nil})
      |> render_submit()

    assert rendered =~ "can&apos;t be blank"
  end
end
