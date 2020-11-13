defmodule WatwitterWeb.Live.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

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

  defp post_card(post) do
    "#post-#{post.id}"
  end
end
