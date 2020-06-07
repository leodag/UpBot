use Mix.Config

config :up_bot, UpBot.Repo,
  database: "up_bot_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :up_bot,
  ecto_repos: [UpBot.Repo]

import_config "telegram_api_token.secret.exs"
