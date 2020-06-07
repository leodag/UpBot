defmodule UpBot do
  @moduledoc false

  use GenServer
  require Logger
  import Crontab.CronExpression

  @groups [{id, ~e[* * * * *]}]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_opts) do
    for {id, cron} <- @groups do
      UpBot.Scheduler.schedule(id, "up", cron)
    end

    send(self(), {:update, 0})
    {:ok, []}
  end

  def handle_info({:update, id}, state) do
    {:ok, updates} = Nadia.get_updates(offset: id)

    id = process_updates(updates)

    Process.send_after(self(), {:update, id + 1}, 1000)
    {:noreply, state}
  end

  def process_updates([]), do: -1

  def process_updates(updates) when is_list(updates) do
    updates
    |> Enum.reduce(fn update, _id -> process_update(update) end)
  end

  @message_types [:message, :edited_message]
  def process_update(update = %Nadia.Model.Update{}) do
    message_type =
      Stream.map(
        @message_types,
        fn type ->
          if Map.has_key?(update, type), do: type
        end
      )
      |> Enum.find(&Function.identity/1)

    case message_type do
      :message ->
        update.update_id
    end
  end
end
