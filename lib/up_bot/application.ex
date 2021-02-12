defmodule UpBot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      {UpBot.Repo, []},
      # Start the Telemetry supervisor
      UpBotWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: UpBot.PubSub},
      # Start the Endpoint (http/https)
      UpBotWeb.Endpoint,
      {UpBot.Scheduler, [name: UpBot.Scheduler]},
      UpBot.ReferenceTracker,
      {UpBot.Bot, [name: UpBot.Bot]},
    ]

    opts = [strategy: :one_for_all, name: UpBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    UpBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
