defmodule WatwitterWeb.PostLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  @create_attrs %{
    body: "some body",
    username: "some username"
  }
  @invalid_attrs %{body: nil, username: nil}

  describe "Index" do
    test "lists all posts", %{conn: conn} do
      post = create(:post)

      {:ok, _view, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Listing Posts"
      assert html =~ post.body
    end

    test "doest not allow blank posts", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))

      view
      |> element("a", "New Post")
      |> render_click()

      rendered =
        view
        |> form("#post-form", post: @invalid_attrs)
        |> render_change()

      assert rendered =~ "can&apos;t be blank"
    end

    test "saves new post", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.post_index_path(conn, :index))

      view
      |> element("a", "New Post")
      |> render_click()

      {:ok, _, html} =
        view
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
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

  defp create(:post, attrs \\ @create_attrs) do
    {:ok, post} = Timeline.create_post(attrs)
    post
  end
end
