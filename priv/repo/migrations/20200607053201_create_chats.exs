defmodule UpBot.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :message, :string
      add :schedule, :map

      timestamps()
    end
  end
end
