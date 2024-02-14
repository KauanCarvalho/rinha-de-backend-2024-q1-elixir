defmodule BackendFightWeb.HealthcheckControllerTest do
  use BackendFightWeb.ConnCase
  use ExUnit.Case, async: true

  test "GET /healthcheck, when everything happens as it should, it is expected to return 200 without a body", %{
    conn: conn
  } do
    conn = conn |> get("/healthcheck")

    assert("" == response(conn, 200))
  end
end
