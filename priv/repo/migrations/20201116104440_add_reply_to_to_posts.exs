defmodule Watwitter.Repo.Migrations.AddReplyToToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :reply_to_id, references(:posts, on_delete: :nilify_all)
    end

    create index(:posts, [:reply_to_id])
  end
end
