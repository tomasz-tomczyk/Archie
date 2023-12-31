defmodule Archie.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ArchieWeb.Telemetry,
      # Start the Ecto repository
      Archie.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Archie.PubSub},
      # Start Finch
      {Finch, name: Archie.Finch},
      # Start the Endpoint (http/https)
      ArchieWeb.Endpoint
      # Start a worker by calling: Archie.Worker.start_link(arg)
      # {Archie.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Archie.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    ArchieWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
