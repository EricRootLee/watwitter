defmodule WatwitterWeb.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  import Mox

  setup :verify_on_exit!
  setup :register_and_log_in_user

  setup do
    Mox.stub_with(FakeTimer, ImmediateTimer)

    :ok
  end

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

  test "LiveView checks for new messages periodically (waiting approach)", %{conn: conn} do
    # user real timer (as if we weren't using Mox)
    Mox.stub_with(FakeTimer, Watwitter.Timer.Impl)

    {:ok, view, _html} = live(conn, "/")

    render(view)

    refute has_element?(view, ".new-posts-notice")

    insert(:post)

    Process.sleep(1000)

    assert has_element?(view, ".new-posts-notice", "1")
  end

  test "LiveView checks for new messages periodically (test is quasi-timer)", %{conn: conn} do
    # user real timer (as if we weren't using Mox)
    Mox.stub_with(FakeTimer, Watwitter.Timer.Impl)
    {:ok, view, _html} = live(conn, "/")

    render(view)

    refute has_element?(view, ".new-posts-notice")

    insert(:post)

    send(view.pid, :check_new_posts)

    assert has_element?(view, ".new-posts-notice", "1")
  end

  test "LiveView establishes a timer", %{conn: conn} do
    Application.put_env(:watwitter, :timeline_timer, FakeTimer)
    test_pid = self()

    FakeTimer
    |> expect(:send_interval, fn 1000, _pid, message_to_send ->
      send(test_pid, {:timer_requested, message_to_send})
      :ok
    end)

    {:ok, view, _html} = live(conn, "/")
    assert_receive {:timer_requested, message_to_send}
    refute has_element?(view, ".new-posts-notice")

    ## Test the post notice
    insert(:post)
    send(view.pid, message_to_send)

    assert has_element?(view, ".new-posts-notice", "1")
  end
end
