defmodule Watwitter.Repo.Migrations.AddAvatarUrlToAccountUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar_url, :string, null: false, default: "https://www.gravatar.com/avatar/asdf"
    end
  end
end
