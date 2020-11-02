defmodule WatwitterWeb.PostLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  describe "Index" do
    test "lists all posts", %{conn: conn} do
      post = create(:post)

      {:ok, _view, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Listing Posts"
      assert html =~ post.body
    end
  end

  describe "Show" do
    test "displays post", %{conn: conn} do
      post = create(:post)

      {:ok, _view, html} = live(conn, Routes.post_show_path(conn, :show, post))

      assert html =~ "Show Post"
      assert html =~ post.body
    end
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
