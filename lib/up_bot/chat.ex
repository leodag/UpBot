defmodule UpBot.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field(:message, :string)
    field(:schedule, Crontab.CronExpression.Ecto.Type)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
