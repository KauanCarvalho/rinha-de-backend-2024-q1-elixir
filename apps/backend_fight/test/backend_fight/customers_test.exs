defmodule BackendFight.CustomersTest do
  use DB.DataCase
  use ExUnit.Case, async: true

  import DB.Factory
  import Ecto.Query, only: [from: 2]

  alias BackendFight.Customers
  alias DB.Repo
  alias DB.Schemas.{Customer, Transaction}

  test "find_for_customer_information/1, when given something other than string or integer it is expected to return the appropriate error" do
    assert({:error, :invalid_customer_id} = Customers.find_for_customer_information(%{}))
  end

  test "find_for_customer_information/1, when provided something that cannot be a `customer_id` it is expected to return the appropriate error" do
    assert({:error, :invalid_customer_id} = Customers.find_for_customer_information("jhon-doe"))
  end

  test "find_for_customer_information/1, when provided a non-existent id it is expected to return an appropriate error" do
    assert({:error, :not_found} = Customers.find_for_customer_information("9999999999"))
  end

  test "find_for_customer_information/1, when the client has no transactions, the client is expected to return an empty list of transactions" do
    %Customer{id: customer_id} = insert(:customer)

    assert(
      0 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )

    assert({:ok, %Customer{id: ^customer_id, transactions: []}} = Customers.find_for_customer_information(customer_id))
  end

  test "find_for_customer_information/1 when the client has an acceptable list of transactions, it is expected to return all of them" do
    %Customer{id: customer_id} = customer = insert(:customer)
    transactions = insert_list(7, :transaction, customer: customer)
    transactions_ids = Enum.map(transactions, & &1.id)

    assert(
      7 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )

    assert(
      {:ok, %Customer{id: ^customer_id, transactions: result_transactions}} =
        Customers.find_for_customer_information(customer_id)
    )

    result_transactions_ids = Enum.map(result_transactions, & &1.id)

    assert(Enum.empty?(result_transactions_ids -- transactions_ids))
  end

  test "find_for_customer_information/1When the client has a larger than expected list of transactions, it is expected to return the latest ones" do
    %Customer{id: customer_id} = customer = insert(:customer)

    insert_list(Customers.number_of_serialized_transactions(), :transaction,
      customer: customer,
      inserted_at: DateTime.utc_now() |> DateTime.add(-3600, :second)
    )

    # Only the relevant ones to be used.
    last_transactions = insert_list(Customers.number_of_serialized_transactions(), :transaction, customer: customer)
    last_transactions_ids = Enum.map(last_transactions, & &1.id)

    assert(
      Customers.number_of_serialized_transactions() * 2 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )

    assert(
      {:ok, %Customer{id: ^customer_id, transactions: result_transactions}} =
        Customers.find_for_customer_information(customer_id)
    )

    result_transactions_ids = Enum.map(result_transactions, & &1.id)

    assert(Enum.empty?(result_transactions_ids -- last_transactions_ids))
  end

  test "number_of_serialized_transactions/0, is expected to return the number of serialized transactions" do
    assert(10 == Customers.number_of_serialized_transactions())
  end

  test "create_transaction_and_refresh_balance/2, when the `customer_id` entered does not agree, it is expected to return an appropriate error" do
    assert({:error, :invalid_customer_id} == Customers.create_transaction_and_refresh_balance(%{}, "foo"))
  end

  test "create_transaction_and_refresh_balance/2, when the `customer_id` entered can be converted to an integer but the customer is not found, it is expected to return an appropriate error" do
    assert(
      {:error, :locked_customer, :not_found, %{}} == Customers.create_transaction_and_refresh_balance(%{}, "999999999")
    )
  end

  test "cWhen the customer is found and it is a debit transaction, it is expected to create the transaction and update the customer's balance" do
    %Customer{id: customer_id, balance: old_balance, limit_amount: limit_amount} = insert(:customer)

    attrs = %{
      amount: 1,
      type: "d",
      description: "bar"
    }

    assert(
      0 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )

    new_balance = old_balance - attrs.amount

    assert(
      {:ok,
       %{
         transaction: %DB.Schemas.Transaction{},
         locked_customer: %DB.Schemas.Customer{id: ^customer_id, limit_amount: ^limit_amount, balance: ^old_balance},
         customer_updated: %DB.Schemas.Customer{id: ^customer_id, limit_amount: ^limit_amount, balance: ^new_balance}
       }} = Customers.create_transaction_and_refresh_balance(attrs, customer_id)
    )

    assert(
      1 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )
  end

  test "cWhen the customer is found and it is a credit transaction, it is expected to create the transaction and update the customer's balance" do
    %Customer{id: customer_id, balance: old_balance, limit_amount: limit_amount} = insert(:customer)

    attrs = %{
      amount: 3,
      type: "c",
      description: "foo"
    }

    assert(
      0 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )

    new_balance = old_balance + attrs.amount

    assert(
      {:ok,
       %{
         transaction: %DB.Schemas.Transaction{},
         locked_customer: %DB.Schemas.Customer{id: ^customer_id, limit_amount: ^limit_amount, balance: ^old_balance},
         customer_updated: %DB.Schemas.Customer{id: ^customer_id, limit_amount: ^limit_amount, balance: ^new_balance}
       }} = Customers.create_transaction_and_refresh_balance(attrs, customer_id)
    )

    assert(
      1 ==
        from(transaction in Transaction, where: transaction.customer_id == ^customer_id, select: count(transaction.id))
        |> Repo.one()
    )
  end
end
