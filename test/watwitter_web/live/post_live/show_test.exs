defmodule WatwitterWeb.PostLive.ShowTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  setup :register_and_log_in_user

  test "displays post", %{conn: conn} do
    post = insert(:post)

    {:ok, _view, html} = live(conn, Routes.post_show_path(conn, :show, post))

    assert html =~ post.body
    assert html =~ post.user.username
    assert html =~ post.user.name
  end
end
