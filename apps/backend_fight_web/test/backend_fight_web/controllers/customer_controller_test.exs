defmodule BackendFightWeb.CustomerControllerTest do
  use BackendFightWeb.ConnCase
  use ExUnit.Case, async: true

  import DB.Factory

  alias DB.Repo
  alias DB.Schemas.{Customer, Transaction}

  describe "GET /clientes/:id/extrato" do
    test "when there is no client for the given id, it is expected to return 404" do
      customer_id = "9999999999"

      conn =
        build_conn()
        |> get("/clientes/#{customer_id}/extrato", %{})

      assert(is_nil(Repo.get(Customer, customer_id)))

      assert("" == response(conn, 404))
    end

    test "when something unexpected is passed as a client reference, it is expected to return 422" do
      customer_id = "jhon-doe"

      conn =
        build_conn()
        |> get("/clientes/#{customer_id}/extrato", %{})

      assert("" == response(conn, 422))
    end

    test "2hen everything happens as it should, it is expected to return the client, its transactions and http status code 200" do
      %Transaction{
        amount: amount,
        type: type,
        description: description,
        customer: %Customer{id: customer_id, balance: balance, limit_amount: limit_amount}
      } = insert(:transaction)

      conn =
        build_conn()
        |> get("/clientes/#{customer_id}/extrato", %{})

      refute(is_nil(Repo.get(Customer, customer_id)))

      converted_type = Atom.to_string(type)

      assert(
        %{
          "saldo" => %{
            "total" => ^balance,
            "data_extrato" => _,
            "limite" => ^limit_amount
          },
          "ultimas_transacoes" => [
            %{
              "valor" => ^amount,
              "tipo" => ^converted_type,
              "descricao" => ^description,
              "realizada_em" => _
            }
          ]
        } = json_response(conn, 200)
      )
    end
  end
end
