defmodule DB.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DB.Repo
    ]

    opts = [strategy: :one_for_one, name: DB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
