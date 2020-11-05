defmodule WatwitterWeb.PostLive.FormComponentTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{
    username: "germsvel",
    body: "some body"
  }
  @invalid_attrs %{username: nil, body: nil}
  @two_fifty_one ~S"""
  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua. Ut tortor pretium viverra
    suspendisse potenti nullam ac. Turpis egestas maecenas pharetra convallis
    posuere morbi leo urna molestie. Nunc consequat interdumv
  """
  @attrs_251_chars %{username: "germsvel", body: @two_fifty_one}

  test "does not allow blank posts", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.post_new_path(conn, :new))

    rendered =
      view
      |> form("#post-form", post: @invalid_attrs)
      |> render_change()

    assert rendered =~ "can&apos;t be blank"
  end

  test "does not allow posts with more than 250 characters", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.post_new_path(conn, :new))

    rendered =
      view
      |> form("#post-form", post: @attrs_251_chars)
      |> render_change()

    assert rendered =~ "should be at most 250 character(s)"
  end

  test "saves new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.post_new_path(conn, :new))

    {:ok, _, html} =
      view
      |> form("#post-form", post: @create_attrs)
      |> render_submit()
      |> follow_redirect(conn, Routes.post_index_path(conn, :index))

    assert html =~ "Post created successfully"
    assert html =~ "some body"
  end
end
