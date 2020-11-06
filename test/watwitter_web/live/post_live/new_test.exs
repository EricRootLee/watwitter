defmodule WatwitterWeb.PostLive.NewTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "page_title is set", %{conn: conn} do
    {:ok, _, html} = live(conn, Routes.post_new_path(conn, :new))

    assert html =~ "Compose Watweet"
  end

  test "renders form to compose post", %{conn: conn} do
    {:ok, _, html} = live(conn, Routes.post_new_path(conn, :new))

    assert html =~ "post-form"
  end
end
