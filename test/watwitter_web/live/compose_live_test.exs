defmodule WatwitterWeb.ComposeLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "compose displys user avatar", %{conn: conn, user: user} do
    {:ok, _view, html} = live(conn, Routes.compose_path(conn, :new))

    assert html =~ user.avatar_url
  end

  test "user can navigate back to timeline", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    {:ok, _timeline_view, html} =
      view
      |> element("#back")
      |> render_click()
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert html =~ "Home"
  end

  test "user can compose a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    {:ok, timeline_view, _html} =
      view
      |> form("#new-post", post: %{body: "This is amazing"})
      |> render_submit()
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert has_element?(timeline_view, ".post", "This is amazing")
  end

  test "user cannot submit empty post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    rendered =
      view
      |> form("#new-post", post: %{body: nil})
      |> render_submit()

    assert rendered =~ "can&apos;t be blank"
  end

  @two_hundred_and_fifty_one """
  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut tortor pretium
    viverra suspendisse potenti nullam ac. Turpis egestas maecenas pharetra
    convallis posuere morbi leonur
  """
  test "user sees errors when interacting with form", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    rendered =
      view
      |> form("#new-post", post: %{body: @two_hundred_and_fifty_one})
      |> render_change()

    assert rendered =~ "should be at most 250 character(s)"
  end
end
