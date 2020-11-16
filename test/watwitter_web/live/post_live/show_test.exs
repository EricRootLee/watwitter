defmodule WatwitterWeb.Live.PostLive.ShowTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  test "redirects to log in when unauthenticated", %{conn: conn} do
    {:error, {:redirect, %{to: path}}} = live(conn, Routes.post_show_path(conn, :show, 23))

    assert path == Routes.user_session_path(conn, :new)
  end

  test "renders post", %{conn: conn} do
    post = insert(:post)
    conn = log_in_user(conn)
    {:ok, _view, html} = live(conn, Routes.post_show_path(conn, :show, post))

    assert html =~ "Watweet"
    assert html =~ post.body
    assert html =~ post.user.username
    assert html =~ post.user.name
    assert html =~ post.user.avatar_url
  end

  test "renders post with replies", %{conn: conn} do
    post = insert(:post)
    replies = insert_pair(:post, reply_to: post)
    conn = log_in_user(conn)
    {:ok, _view, html} = live(conn, Routes.post_show_path(conn, :show, post))

    assert html =~ "Watweet"

    Enum.each(replies, fn reply ->
      assert html =~ reply.body
      assert html =~ reply.user.username
      assert html =~ reply.user.name
      assert html =~ reply.user.avatar_url
    end)
  end

  test "user can like and repost", %{conn: conn} do
    post = insert(:post, likes_count: 0, reposts_count: 0)
    conn = log_in_user(conn)

    {:ok, view, _html} = live(conn, Routes.post_show_path(conn, :show, post))

    view
    |> element(post_like_button(post))
    |> render_click()

    view
    |> element(post_repost_button(post))
    |> render_click()

    assert has_element?(view, post_like_count(post), "1")
    assert has_element?(view, post_repost_count(post), "1")
  end

  defp post_like_button(post), do: post_card(post) <> " [data-role='like-button']"
  defp post_like_count(post), do: post_card(post) <> " [data-role='like-count']"
  defp post_repost_button(post), do: post_card(post) <> " [data-role='repost-button']"
  defp post_repost_count(post), do: post_card(post) <> " [data-role='repost-count']"
  defp post_card(post), do: "#post-#{post.id}"
end
