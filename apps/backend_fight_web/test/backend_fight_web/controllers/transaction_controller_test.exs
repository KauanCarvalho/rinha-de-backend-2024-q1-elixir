defmodule BackendFightWeb.TransactionControllerTest do
  use BackendFightWeb.ConnCase
  use ExUnit.Case, async: true

  import DB.Factory
  import Ecto.Query, only: [from: 2]

  alias DB.Repo
  alias DB.Schemas.{Customer, Transaction}

  describe "POST /clientes/:id/transacoes" do
    test "when there is no client for the given id, it is expected to return 404" do
      customer_id = "9999999999"

      conn =
        build_conn()
        |> post("/clientes/#{customer_id}/transacoes", %{
          valor: 1,
          tipo: "c",
          descricao: "foo"
        })

      assert(is_nil(Repo.get(Customer, customer_id)))

      assert("" == response(conn, 404))
    end

    test "when `customer_id` cannot be converted, it is expected to return 422" do
      customer_id = "foo"

      conn =
        build_conn()
        |> post("/clientes/#{customer_id}/transacoes", %{
          valor: 1,
          tipo: "c",
          descricao: "foo"
        })

      assert("" == response(conn, 422))
    end

    test "when there is a validation error, it is expected to return 422" do
      %Customer{id: customer_id, balance: old_balance} = customer = insert(:customer)

      assert(
        0 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      conn =
        build_conn()
        |> post("/clientes/#{customer_id}/transacoes", %{
          valor: 1,
          tipo: "b",
          descricao: "foo"
        })

      assert("" == response(conn, 422))

      assert(
        0 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      # Not changes.
      assert(%Customer{id: ^customer_id, balance: ^old_balance} = customer |> Repo.reload())
    end

    test "when the customer's balance will exceed the limit it is expected to return 422" do
      %Customer{id: customer_id, balance: old_balance, limit_amount: limit_amount} = customer = insert(:customer)

      assert(
        0 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      conn =
        build_conn()
        |> post("/clientes/#{customer_id}/transacoes", %{
          valor: limit_amount + 1,
          tipo: "d",
          descricao: "foo"
        })

      assert("" == response(conn, 422))

      assert(
        0 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      # Not changes.
      assert(%Customer{id: ^customer_id, balance: ^old_balance} = customer |> Repo.reload())
    end

    test "When it comes to a successful credit operation, it is expected to respect the contract" do
      %Customer{id: customer_id, balance: old_balance, limit_amount: limit_amount} = customer = insert(:customer)
      amount_param = 100

      assert(
        0 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      conn =
        build_conn()
        |> post("/clientes/#{customer_id}/transacoes", %{
          valor: amount_param,
          tipo: "c",
          descricao: "bar"
        })

      new_balance = old_balance + amount_param

      assert(
        %{
          "limite" => ^limit_amount,
          "saldo" => ^new_balance
        } = json_response(conn, 200)
      )

      assert(
        1 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      assert(%Customer{id: ^customer_id, balance: ^new_balance} = customer |> Repo.reload())
    end

    test "When it comes to a successful debit operation, it is expected to respect the contract" do
      %Customer{id: customer_id, balance: old_balance, limit_amount: limit_amount} =
        customer = insert(:customer, balance: 0, limit_amount: 101)

      amount_param = 100

      assert(
        0 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      conn =
        build_conn()
        |> post("/clientes/#{customer_id}/transacoes", %{
          valor: amount_param,
          tipo: "d",
          descricao: "bar"
        })

      new_balance = old_balance - amount_param

      assert(
        %{
          "limite" => ^limit_amount,
          "saldo" => ^new_balance
        } = json_response(conn, 200)
      )

      assert(
        1 ==
          from(transaction in Transaction,
            where: transaction.customer_id == ^customer_id,
            select: count(transaction.id)
          )
          |> Repo.one()
      )

      assert(%Customer{id: ^customer_id, balance: ^new_balance} = customer |> Repo.reload())
    end
  end
end
