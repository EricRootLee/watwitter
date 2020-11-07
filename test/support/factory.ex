defmodule Watwitter.Factory do
  use ExMachina.Ecto, repo: Watwitter.Repo

  alias Watwitter.{Accounts.User, Repo}

  def user_factory do
    %User{
      email: sequence(:email, &"user#{&1}@example.com"),
      password: "hello world!"
    }
  end

  def register_user(attrs) do
    {:ok, user} =
      %User{}
      |> User.registration_changeset(attrs)
      |> Repo.insert()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
