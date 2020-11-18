defmodule WatwitterWeb.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  setup :register_and_log_in_user

  test "renders home page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Home"
    assert render(view) =~ "Home"
  end

  test "renders users avatar", %{conn: conn, user: user} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ user.avatar_url
    assert render(view) =~ user.avatar_url
  end

  test "renders a list of posts", %{conn: conn} do
    [post1, post2] = insert_pair(:post)
    {:ok, view, _html} = live(conn, "/")

    render(view)

    assert has_element?(view, "#post-#{post1.id}")
    assert has_element?(view, "#post-#{post2.id}")
  end

  test "user can navigate to create a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, _compose_view, html} =
      view
      |> element("#compose-button")
      |> render_click()
      |> follow_redirect(conn, Routes.compose_path(conn, :new))

    assert html =~ "Compose"
  end

  test "user receives notification of new posts", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Alternatives
    # ------------
    # send(view.pid, {:post_created, post})
    #   - doesn't account for broadcast through PubSub. TimelineLive need not be
    #   subscribed. And we want to test the behavior of TimelienLive received
    #   broadcasted messages.
    #
    # Timeline.create_post(post_params)
    #   - Ties this test to Timeline's implementation. What if
    #   Timeline.create_post isn't what broadcasts the message later? (e.g.
    #   maybe the PostComponent does the broadcasting. This test would break.
    #   Should it be coupled to that?
    #
    # Extract this into a single place so at least "posts" and {:post_created,
    # post} are behind an interface that is used by all places. Reduces
    # fragility while giving us flexibility
    Phoenix.PubSub.broadcast(Watwitter.PubSub, "posts", {:post_created, %{}})
    Phoenix.PubSub.broadcast(Watwitter.PubSub, "posts", {:post_created, %{}})

    assert has_element?(view, new_posts_notice(), "2")
  end

  test "user can see new posts when clicking on notification of new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    post = insert(:post)
    Phoenix.PubSub.broadcast(Watwitter.PubSub, "posts", {:post_created, post})

    view
    |> element(new_posts_notice())
    |> render_click()

    assert has_element?(view, post_card(post))
    refute has_element?(view, new_posts_notice())
  end

  defp post_card(%{id: id}), do: "#post-#{id}"

  defp new_posts_notice do
    "#new-posts-notice"
  end
end
