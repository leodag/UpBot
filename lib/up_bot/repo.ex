defmodule UpBot.Repo do
  use Ecto.Repo,
    otp_app: :up_bot,
    adapter: Ecto.Adapters.Postgres
end
