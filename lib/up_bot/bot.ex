defmodule UpBot.Bot do
  @moduledoc false

  defmodule Context do
    defstruct [
      :kind,
      :origin,
      :update,
      :update_type,
      :return_to,
      :command,
      :split_args,
      :single_arg,
      :message_text
    ]
  end

  use GenServer
  require Logger
  alias UpBot.Repo
  alias UpBot.Chat

  @update_types [:message, :edited_message]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_opts) do
    Logger.debug("Initializing bot")
    chats = Repo.all(Chat)

    for %Chat{id: id, message: message, schedule: cron} <- chats do
      UpBot.schedule_up(id, message, cron)
    end

    {:ok, me} = Nadia.get_me()

    send(self(), {:update, 0})
    {:ok, %{me: me}}
  end

  def handle_info({:update, id}, state) do
    case Nadia.get_updates(offset: id) do
      {:ok, updates}  ->
        id = process_updates(updates)
        Process.send_after(self(), {:update, id + 1}, 1000)
      {:error, err} ->
        Logger.warn("Error #{err} when polling for updates, retrying")
        Process.send_after(self(), {:update, id}, 0)
    end

    {:noreply, state}
  end

  def update_type(update) do
    @update_types
    |> Stream.map(fn type ->
      if Map.has_key?(update, type), do: type
    end)
    |> Enum.find(&Function.identity/1)
  end

  def unwrap_update(update) do
    type = update_type(update)
    content = Map.fetch!(update, type)
    {type, content}
  end

  def process_updates([]), do: -1

  def process_updates(updates) when is_list(updates) do
    updates
    |> Enum.reduce(nil, fn update, _id -> process_update(update) end)
  end

  def process_update(update = %Nadia.Model.Update{}) do
    {type, content} = unwrap_update(update)
    handle_update(type, content)

    update.update_id
  end

  def get_command(text) do
    case Regex.run(~r|^/([A-Za-z0-9_]+)|, text) do
      [_, command] ->
        {:ok, command}
      nil ->
        :error
    end
  end

  @spec get_context(atom, map) :: Context.t()
  def get_context(:message, message) do
    origin =
      case message.chat.type do
        "private" -> :user
        "group" -> :group
        "supergroup" -> :supergroup
        "channel" -> :channel
      end

    base_context =
      %Context{
        origin: origin,
        update_type: :message,
        update: message,
        return_to: message.chat.id
      }

    kind_context =
      case get_command(message.text) do
        {:ok, command} ->
          rest =
            message.text
            |> String.split(~r|[ \t\n]+|, parts: 2)
            |> Enum.at(1, "")
            |> String.trim() # might have spaces at the end

          split_rest = String.split(rest)

          %{
            kind: :command,
            command: command,
            split_args: split_rest,
            single_arg: rest
          }

        :error ->
          %{
            kind: :text_message,
            message_text: message.text
          }
      end

    struct(base_context, kind_context)
  end

  def dispatch({:command, "setup", ctx}) do
    case Crontab.CronExpression.Parser.parse(ctx.single_arg) do
      {:ok, schedule} ->
        {:ok, _} = UpBot.setup_chat(ctx.return_to, schedule)
        Nadia.send_message(ctx.return_to, "Setup successful")
      {:error, error} ->
        Nadia.send_message(ctx.return_to, "Setup failed: " <> inspect(error))
    end
  end

  def dispatch({:command, "change_schedule", ctx}) do
    case Crontab.CronExpression.Parser.parse(ctx.single_arg) do
      {:ok, schedule} ->
        :ok = UpBot.change_schedule(ctx.return_to, schedule)
        Nadia.send_message(ctx.return_to, "Schedule changed successfully")
      {:error, error} ->
        Nadia.send_message(ctx.return_to, "Schedule change failed: " <> inspect(error))
    end
  end

  def dispatch({:command, "change_message", ctx}) do
    :ok = UpBot.change_message(ctx.return_to, ctx.single_arg)
    Nadia.send_message(ctx.return_to, "Message changed successfully")
  end

  def dispatch({:command, "quit", ctx}) do
    :ok = UpBot.quit_chat(ctx.return_to)
    Nadia.send_message(ctx.return_to, "Quit successfully")
  end

  def handle_update(:message, message) do
    context = get_context(:message, message)
    IO.inspect(context)

    case context.kind do
      :command ->
        dispatch({:command, context.command, context})
      :text_message ->
        Logger.info("Received text message: #{context}")
      _ ->
        Logger.debug("Unknown kind #{message.text}, ignoring")
    end
  end
end
