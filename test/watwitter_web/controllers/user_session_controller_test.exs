defmodule WatwitterWeb.UserSessionControllerTest do
  use WatwitterWeb.ConnCase, async: true

  import Watwitter.Factory

  setup do
    %{user: params_for(:user) |> register_user()}
  end

  describe "GET /users/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.user_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.user_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn} do
      user_params = params_for(:user)
      register_user(user_params)

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user_params.email, "password" => user_params.password}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ "Watwitter"
      assert response =~ "Home"
    end

    test "logs the user in with remember me", %{conn: conn} do
      user_params = params_for(:user)
      register_user(user_params)

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user_params.email,
            "password" => user_params.password,
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["user_remember_me"]
      assert redirected_to(conn) =~ "/"
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end