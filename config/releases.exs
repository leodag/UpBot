import Config

config :up_bot, UpBot.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]

config :nadia,
  token: {:system, "TELEGRAM_TOKEN"}
