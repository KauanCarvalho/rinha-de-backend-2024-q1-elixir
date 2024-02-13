defmodule BackendFight.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BackendFight.Repo,
      {DNSCluster, query: Application.get_env(:backend_fight, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BackendFight.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BackendFight.Finch}
      # Start a worker by calling: BackendFight.Worker.start_link(arg)
      # {BackendFight.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BackendFight.Supervisor)
  end
end
