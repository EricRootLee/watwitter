defmodule WatwitterWeb.PostLive.PostComponentTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Watwitter.Timeline

  describe "likes" do
    test "users can like a post", %{conn: conn} do
      post = create(:post)

      {:ok, view, _} = live(conn, Routes.post_index_path(conn, :index))

      view
      |> element(post_card_like(post))
      |> render_click()

      assert has_element?(view, post_card_like_count(post), "1")
    end
  end

  defp post_card_like(post), do: "#post-#{post.id} [data-role='like-button']"
  defp post_card_like_count(post), do: "#post-#{post.id} [data-role='like-count']"

  defp create(:post) do
    attrs = %{
      username: "germsvel",
      body: "This is a great tutorial"
    }

    {:ok, post} = Timeline.create_post(attrs)
    post
  end
end
