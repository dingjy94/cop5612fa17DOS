defmodule Project4.Mixfile do
  use Mix.Project

  def project do
    [
      app: :project4,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      escript: escript_config(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp escript_config() do 
    [main_module: Project4.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ecto, "~> 2.0"},
    {:postgrex, "~> 0.11"}]
  end
end
