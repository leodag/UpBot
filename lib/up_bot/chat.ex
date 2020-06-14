defmodule UpBot.Chat do
  use Ecto.Schema

  schema "chats" do
    field(:message, :string)
    field(:schedule, Crontab.CronExpression.Ecto.Type)

    timestamps()
  end
end
