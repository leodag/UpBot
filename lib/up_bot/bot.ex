defmodule UpBot.Bot do
  @moduledoc false

  use GenServer
  require Logger
  alias UpBot.Repo
  alias UpBot.Chat

  @update_types [:message, :edited_message]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_opts) do
    chats = Repo.all(Chat)

    for %Chat{id: id, message: message, schedule: cron} <- chats do
      UpBot.schedule_up(id, message, cron)
    end

    {:ok, []}
  end

  def handle_info({:update, id}, state) do
    {:ok, updates} = Nadia.get_updates(offset: id)

    id = process_updates(updates)

    Process.send_after(self(), {:update, id + 1}, 1000)
    {:noreply, state}
  end

  def update_type(update) do
    @update_types
    |> Stream.map(fn type ->
      if Map.has_key?(update, type), do: type
    end)
    |> Enum.find(&Function.identity/1)
  end

  def process_updates([]), do: -1

  def process_updates(updates) when is_list(updates) do
    updates
    |> Enum.reduce(nil, fn update, _id -> process_update(update) end)
  end

  def process_update(update = %Nadia.Model.Update{}) do
    case update_type(update) do
      :message ->
        if update.message.text do
          id = update.message.chat.id
          [command | arguments] = String.split(update.message.text, ~r|[ \t\n]+|, parts: 2)
          command = Regex.run(~r|^/[A-Za-z0-9_]*[^@ ]?|, command)
          arguments = arguments |> Enum.at(0, "") |> String.trim()

          case hd(command) do
            "/setup" ->
              case Crontab.CronExpression.Parser.parse(arguments) do
                {:ok, schedule} ->
                  {:ok, _} = UpBot.setup_chat(id, schedule)
                  Nadia.send_message(id, "Setup successful")
                {:error, error} ->
                  Nadia.send_message(id, "Setup failed: " <> inspect(error))
              end

            "/change_schedule" ->
              case Crontab.CronExpression.Parser.parse(arguments) do
                {:ok, schedule} ->
                  {:ok, _} = UpBot.change_schedule(id, schedule)
                  Nadia.send_message(id, "Schedule changed successfully")
                {:error, error} ->
                  Nadia.send_message(id, "Schedule change failed: " <> inspect(error))
              end

            "/change_message" ->
              {:ok, _} = UpBot.change_message(id, arguments)
              Nadia.send_message(id, "Message changed successfully")

            "/quit" ->
              :ok = UpBot.quit_chat(id)
              Nadia.send_message(id, "Quit successfully")

            cmd ->
              Logger.debug("Unknown command #{cmd}, ignoring")
          end
        end
    end

    update.update_id
  end
end
