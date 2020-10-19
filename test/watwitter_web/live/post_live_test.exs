defmodule WatwitterWeb.PostLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  @create_attrs %{
    body: "some body",
    likes_count: 42,
    reposts_count: 42,
    username: "some username"
  }
  @invalid_attrs %{body: nil, likes_count: nil, reposts_count: nil, username: nil}

  describe "Index" do
    test "lists all posts", %{conn: conn} do
      post = create(:post)

      {:ok, _index_live, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Listing Posts"
      assert html =~ post.body
    end

    test "doest not allow blank posts", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, Routes.post_index_path(conn, :new))

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("a", "New Post") |> render_click() =~
               "New Post"

      assert_patch(index_live, Routes.post_index_path(conn, :new))

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some body"
    end

    test "deletes post in listing", %{conn: conn} do
      post = create(:post)

      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("#post-#{post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#post-#{post.id}")
    end
  end

  describe "Show" do
    test "displays post", %{conn: conn} do
      post = create(:post)

      {:ok, _show_live, html} = live(conn, Routes.post_show_path(conn, :show, post))

      assert html =~ "Show Post"
      assert html =~ post.body
    end
  end

  defp create(:post, attrs \\ @create_attrs) do
    {:ok, post} = Timeline.create_post(attrs)
    post
  end
end
