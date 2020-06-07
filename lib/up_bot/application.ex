defmodule UpBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {UpBot.Scheduler, [name: UpBot.Scheduler]},
      {UpBot, [name: UpBot]},
    ]

    opts = [strategy: :one_for_all, name: UpBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
