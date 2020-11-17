defmodule WatwitterWeb.TimelineLive.PostComponentTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias WatwitterWeb.DateHelpers
  alias WatwitterWeb.TimelineLive.PostComponent

  test "renders post's info: body, date, user's name, username, and avatar" do
    post = insert(:post, likes: [])
    user = post.user

    html = render_component(PostComponent, id: post.id, post: post, current_user: user)

    assert html =~ post.body
    assert html =~ user.name
    assert html =~ "@#{user.username}"
    assert html =~ user.avatar_url
    assert html =~ DateHelpers.format_short(post.inserted_at)
  end
end
