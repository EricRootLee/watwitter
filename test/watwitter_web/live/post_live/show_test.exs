defmodule WatwitterWeb.PostLive.ShowTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  test "displays post", %{conn: conn} do
    post = create(:post)

    {:ok, _view, html} = live(conn, Routes.post_show_path(conn, :show, post))

    assert html =~ post.body
  end

  defp create(:post) do
    attrs = %{
      username: "germsvel",
      body: "some body"
    }

    {:ok, post} = Timeline.create_post(attrs)
    post
  end
end
