defmodule DB.Release do
  @moduledoc """
  Migration module for release
  """

  @app :db

  def migrate do
    load_app()

    for repo <- repos() do
      with value when value in [:ok, {:error, :already_up}] <-
             repo.__adapter__.storage_up(repo.config) do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      end
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(@app)
  end
end
