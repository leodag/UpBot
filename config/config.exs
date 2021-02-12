# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :up_bot,
  ecto_repos: [UpBot.Repo]

# Configures the endpoint
config :up_bot, UpBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fypBLKtzvEEH3vbZqQ9js8R8ULPZVse36zsH4n4FREliSjdIZY62M4WnhzDnK430",
  render_errors: [view: UpBotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: UpBot.PubSub,
  live_view: [signing_salt: "RXD1xXrv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
