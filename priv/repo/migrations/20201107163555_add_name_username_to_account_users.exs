defmodule Watwitter.Repo.Migrations.AddNameUsernameToAccountUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string, null: false
      add :username, :string, null: false
    end

    create unique_index(:users, [:username])
  end
end
