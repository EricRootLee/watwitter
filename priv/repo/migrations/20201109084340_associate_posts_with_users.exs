defmodule Watwitter.Repo.Migrations.AssociatePostsWithUsers do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users), null: false
      remove :username, :string, null: false
    end

    drop unique_index(:users, [:username])
  end
end
