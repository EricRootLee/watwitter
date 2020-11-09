defmodule Watwitter.Factory do
  use ExMachina.Ecto, repo: Watwitter.Repo

  alias Watwitter.{Accounts.User, Repo, Timeline.Post}

  def post_factory do
    %Post{
      body: "This is a most wonderful watweet",
      user: build(:user)
    }
  end

  def valid_user_password, do: "hello world!"

  def user_factory do
    changes = %{
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence("Bilbo Baggins"),
      username: sequence("bilbo"),
      password: valid_user_password()
    }

    %User{}
    |> User.registration_changeset(changes)
    |> Ecto.Changeset.apply_changes()
  end

  def register_user(attrs) do
    attrs = Map.put(attrs, :password, valid_user_password())

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
