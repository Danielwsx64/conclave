defmodule Conclave.MixProject do
  use Mix.Project

  def project do
    [
      app: :conclave,
      version: "0.0.1",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: [test: "test --no-start"]
    ]
  end

  defp elixirc_paths(env) when env in [:test, :dev], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    if Mix.env() in [:dev] do
      [extra_applications: [:logger, :runtime_tools, :observer, :wx]]
    else
      [extra_applications: [:logger]]
    end
  end

  defp deps do
    [
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:local_cluster, "~> 2.0", only: [:test]}
    ]
  end
end
