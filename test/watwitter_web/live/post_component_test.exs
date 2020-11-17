defmodule WatwitterWeb.Live.PostComponentTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.DateHelpers

  test "renders post's body, date, and user's name, username, avatar" do
    user = insert(:user)
    post = insert(:post, user: user)

    html = render_component(PostComponent, post: post)

    assert html =~ post.body
    assert html =~ DateHelpers.format_short(post.inserted_at)
    assert html =~ user.name
    assert html =~ "@#{user.username}"
    assert html =~ user.avatar_url
  end
end
