defmodule UpBot do
  @moduledoc false

  @default_message "up"

  require Logger
  alias UpBot.Repo
  alias UpBot.Chat
  alias Crontab.CronExpression

  import Ecto.Changeset, only: [change: 2]

  @spec get_initial_chats :: [Chat.t()]
  def get_initial_chats do
    Repo.all(Chat)
  end

  @spec setup_chat(integer, CronExpression.t()) :: {:ok, CronExpression.name()}
  def setup_chat(id, cron) do
    {:ok, _} = Repo.insert(%Chat{id: id, message: @default_message, schedule: cron})
    schedule_up(id, @default_message, cron)
  end

  @spec quit_chat(integer) :: :ok
  def quit_chat(id) do
    {:ok, _} = Repo.delete(%Chat{id: id})
    unschedule_up(id)
  end

  @spec schedule_up(integer, String.t(), CronExpression.t()) :: {:ok, CronExpression.name()}
  def schedule_up(id, message, cron) do
    Logger.debug(
      "Scheduling up message \"" <>
        message <>
        "\" on schedule " <>
        inspect(cron) <>
        " to chat " <>
        to_string(id)
    )

    {:ok, ref} = UpBot.Scheduler.schedule(id, message, cron)
    UpBot.ReferenceTracker.put(id, ref)

    {:ok, ref}
  end

  @spec unschedule_up(integer) :: :ok
  def unschedule_up(id) do
    UpBot.ReferenceTracker.get(id)
    |> UpBot.Scheduler.delete_job()

    UpBot.ReferenceTracker.delete(id)
  end

  def change_message(id, message) do
    {:ok, chat} =
      Repo.get!(Chat, id)
      |> change(message: message)
      |> Repo.update()

    unschedule_up(chat.id)
    schedule_up(chat.id, chat.message, chat.schedule)
  end

  def change_schedule(id, schedule) do
    {:ok, chat} =
      Repo.get!(Chat, id)
      |> change(schedule: schedule)
      |> Repo.update()

    unschedule_up(chat.id)
    schedule_up(chat.id, chat.message, chat.schedule)
  end
end
