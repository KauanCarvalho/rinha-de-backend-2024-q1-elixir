defmodule BackendFight.Customers do
  @moduledoc """
    Customers context
  """

  @number_of_serialized_transactions 10

  import Ecto.Query, only: [from: 2]

  alias DB.Repo
  alias DB.Schemas.{Customer, Transaction}

  @doc """
  Finds for customer data and their latest transactions.

  ## Examples

      iex> find_for_customer_information(%{})
      {:error, "invalid customer id"}

      iex> find_for_customer_information("jhon-doe")
      {:error, "invalid customer id"}

      iex> find_for_customer_information("999")
      {:error, "not found"}

      iex> find_for_customer_information("1")
      {:ok, %DB.Schemas.Customer{id: 1, transactions: [#DB.Schemas.Transaction{}, ...]}}

      iex> find_for_customer_information(1)
      {:ok, %DB.Schemas.Customer{id: 1, transactions: [#DB.Schemas.Transaction{}, ...]}}

  """
  def find_for_customer_information(customer_id) when is_binary(customer_id) do
    case Integer.parse(customer_id) do
      {parsed_customer_id, ""} -> find_for_customer_information(parsed_customer_id)
      _ -> {:error, "invalid customer id"}
    end
  end

  def find_for_customer_information(customer_id) when is_integer(customer_id) do
    transaction_query =
      from(transaction in Transaction,
        order_by: [desc: transaction.inserted_at],
        limit: @number_of_serialized_transactions
      )

    query =
      from(customer in Customer,
        where: customer.id == ^customer_id,
        preload: [transactions: ^transaction_query]
      )

    case Repo.one(query) do
      nil -> {:error, "not found"}
      result -> {:ok, result}
    end
  end

  def find_for_customer_information(_), do: {:error, "invalid customer id"}

  @doc """
  Number of serialized sessions.

  ## Examples

      iex> number_of_serialized_transactions()
      10

  """
  def number_of_serialized_transactions, do: @number_of_serialized_transactions
end
