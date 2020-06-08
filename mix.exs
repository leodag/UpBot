defmodule UpBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :up_bot,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {UpBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nadia, "~> 0.6.0"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},
    ]
  end
end
