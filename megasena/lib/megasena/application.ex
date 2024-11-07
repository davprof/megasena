defmodule Megasena.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    numbers = 6
    guesses = 10

    children = [
      MegasenaWeb.Telemetry,
      # Megasena.Repo,
      {DNSCluster, query: Application.get_env(:megasena, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Megasena.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Megasena.Finch},
      # Start a worker by calling: Megasena.Worker.start_link(arg)
      # {Megasena.Worker, arg},
      {Megasena.Supervisor, {numbers, guesses}},
      # Start to serve requests, typically the last entry
      MegasenaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Megasena.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MegasenaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
