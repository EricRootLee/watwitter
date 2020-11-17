defmodule WatwitterWeb.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "renders home page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Home"
    assert render(view) =~ "Home"
  end

  test "renders users avatar", %{conn: conn, user: user} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ user.avatar_url
    assert render(view) =~ user.avatar_url
  end
end
