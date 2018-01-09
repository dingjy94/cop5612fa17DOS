defmodule Project4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    # children = [
      # Starts a worker by calling: Project4.Worker.start_link(arg)
      # {Project4.Worker, arg},
    # ]
    import Supervisor.Spec

    children = [
      Project4.Repo,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Project4.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
