defmodule WatwitterWeb.Live.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  test "redirects to login page if unauthenticated", %{conn: conn} do
    {:error, {:redirect, %{to: path}}} = live(conn, "/")

    assert path == Routes.user_session_path(conn, :new)
  end

  test "renders the Home page", %{conn: conn} do
    {:ok, view, html} = conn |> log_in_user() |> live("/")

    assert html =~ "Home"
    assert render(view) =~ "Home"
  end
end
