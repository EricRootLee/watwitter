defmodule WatwitterWeb.UserRegistrationControllerTest do
  use WatwitterWeb.ConnCase, async: true

  import Watwitter.Factory

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Log in</a>"
      assert response =~ "Register"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = params_for(:user) |> register_user()
      conn = conn |> log_in_user(user) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      user_params = string_params_for(:user)

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => user_params
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ "Watwitter"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
