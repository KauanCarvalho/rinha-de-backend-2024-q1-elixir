defmodule BackendFightWeb.HealthcheckController do
  use BackendFightWeb, :controller

  alias DB.Repo
  alias Ecto.Adapters.SQL

  def index(conn, _params) do
    {:ok, _result} = check_database()

    conn |> send_resp(200, "")
  end

  defp check_database, do: SQL.query(Repo, "select 1", [])
end
