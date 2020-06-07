defmodule UpBot.Scheduler do
  use Quantum.Scheduler, otp_app: :up_bot

  def schedule(id, message, cron) do
    new_job()
    |> Quantum.Job.set_name(:ticker)
    |> Quantum.Job.set_schedule(cron)
    |> Quantum.Job.set_task(fn -> Nadia.send_message(id, message) end)
    |> add_job()
  end
end
