defmodule WatwitterWeb.Live.PostComponentTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.DateHelpers

  test "renders post's body, date, and user's name, username, avatar" do
    user = insert(:user)
    post = insert(:post, user: user)

    html = render_component(PostComponent, id: post.id, post: post, current_user: user)

    assert html =~ post.body
    assert html =~ DateHelpers.format_short(post.inserted_at)
    assert html =~ user.name
    assert html =~ "@#{user.username}"
    assert html =~ user.avatar_url
  end

  test "render's like button and count" do
    post = insert(:post, likes_count: 259)

    html = render_component(PostComponent, id: post.id, post: post, current_user: insert(:user))

    assert html =~ "like-button"
    assert html =~ "like-count"
    assert html =~ "259"
  end
end
