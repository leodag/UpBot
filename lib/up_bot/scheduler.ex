defmodule UpBot.Scheduler do
  use Quantum.Scheduler, otp_app: :up_bot

  alias Crontab.CronExpression

  @spec schedule(integer, String.t(), CronExpression.t()) :: {:ok, CronExpression.name()}
  def schedule(id, message, cron) do
    job =
      new_job()
      |> Quantum.Job.set_schedule(cron)
      |> Quantum.Job.set_task(fn -> {:ok, _} = Nadia.send_message(id, message) end)

    :ok = add_job(job)
    {:ok, job.name}
  end
end
