defmodule BackendFight.Customers do
  @moduledoc """
    Customers context
  """

  @number_of_serialized_transactions 10

  import Ecto.Query, only: [from: 2]

  alias DB.Repo
  alias DB.Schemas.{Customer, Transaction}
  alias Ecto.Multi

  @doc """
  Finds for customer data and their latest transactions.

  ## Examples

      iex> find_for_customer_information(%{})
      {:error, :invalid_customer_id}

      iex> find_for_customer_information("jhon-doe")
      {:error, :invalid_customer_id}

      iex> find_for_customer_information("999")
      {:error, :not_found}

      iex> find_for_customer_information("1")
      {:ok, %DB.Schemas.Customer{id: 1, transactions: [#DB.Schemas.Transaction{}, ...]}}

      iex> find_for_customer_information(1)
      {:ok, %DB.Schemas.Customer{id: 1, transactions: [#DB.Schemas.Transaction{}, ...]}}

  """
  def find_for_customer_information(customer_id) when is_binary(customer_id) do
    case Integer.parse(customer_id) do
      {parsed_customer_id, ""} -> find_for_customer_information(parsed_customer_id)
      _ -> {:error, :invalid_customer_id}
    end
  end

  def find_for_customer_information(customer_id) when is_integer(customer_id) do
    transaction_query =
      from(transaction in Transaction,
        order_by: [desc: transaction.inserted_at, desc: transaction.id],
        limit: @number_of_serialized_transactions
      )

    query =
      from(customer in Customer,
        where: customer.id == ^customer_id,
        preload: [transactions: ^transaction_query]
      )

    case Repo.one(query) do
      nil -> {:error, :not_found}
      result -> {:ok, result}
    end
  end

  def find_for_customer_information(_), do: {:error, :invalid_customer_id}

  @doc """
  Number of serialized sessions.

  ## Examples

      iex> number_of_serialized_transactions()
      10

  """
  def number_of_serialized_transactions, do: @number_of_serialized_transactions

  @doc """
  Creates transaction if the data is valid and updates balance respecting the rules.

  ## Examples

      iex> create_transaction_and_refresh_balance(%{amount: 100_000, type: "c", description: "bar"}, 1)
      {:ok,
        %{
          transaction: %DB.Schemas.Transaction{},
          locked_customer: %DB.Schemas.Customer{},
          customer_updated: %DB.Schemas.Customer{}
        }
      }

      iex> create_transaction_and_refresh_balance(%{amount: 100_000, type: "a", description: "bar"}, 1)
      {:error, :transaction, #Ecto.Changeset<>}

  """
  def create_transaction_and_refresh_balance(attrs, customer_id) when is_map(attrs) and is_binary(customer_id) do
    case Integer.parse(customer_id) do
      {parsed_customer_id, ""} -> create_transaction_and_refresh_balance(attrs, parsed_customer_id)
      _ -> {:error, :invalid_customer_id}
    end
  end

  def create_transaction_and_refresh_balance(attrs, customer_id) when is_map(attrs) and is_integer(customer_id) do
    complete_attrs = attrs |> Map.put(:customer_id, customer_id)

    Multi.new()
    |> Multi.run(:locked_customer, fn _repo, _args -> find_customer_for_update(customer_id) end)
    |> Multi.insert(:transaction, fn %{locked_customer: %Customer{balance: current_balance, limit_amount: limit_amount}} ->
      %Transaction{}
      |> Transaction.changeset(complete_attrs)
      |> Transaction.validate_new_balance(current_balance, limit_amount)
    end)
    |> Multi.update(:customer_updated, fn %{locked_customer: locked_customer} ->
      update_customer_balance_changeset(locked_customer, attrs)
    end)
    |> Repo.transaction()
  end

  defp find_customer_for_update(customer_id) do
    query = from(customer in Customer, where: customer.id == ^customer_id, lock: fragment("FOR UPDATE"))

    case Repo.one(query) do
      %Customer{} = customer -> {:ok, customer}
      _ -> {:error, :not_found}
    end
  end

  defp update_customer_balance_changeset(customer, %{type: "d", amount: amount}) do
    Customer.changeset(customer, %{balance: customer.balance - amount})
  end

  defp update_customer_balance_changeset(customer, %{type: "c", amount: amount}) do
    Customer.changeset(customer, %{balance: customer.balance + amount})
  end
end
