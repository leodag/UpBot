import Config

config :up_bot, UpBot.Repo,
  url: {:system, "DATABASE_URL"},
  pool_size: {:system, "POOL_SIZE"}

config :nadia,
  token: {:system, "TELEGRAM_TOKEN"}
