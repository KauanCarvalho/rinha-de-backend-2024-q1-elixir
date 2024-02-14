defmodule DB.Schemas.TransactionTest do
  alias Ecto.Repo.Transaction
  use DB.DataCase

  import DB.Factory

  alias DB.Schemas.Transaction
  alias Ecto.Changeset

  customer = insert(:customer)
  @valid_attrs %{amount: 100, type: "c", description: "foo", customer_id: customer.id}
  @invalid_attrs %{amount: nil, type: "cd", description: "foobarjohndoe", customer_id: nil}

  test "changeset/1, when attributes are valid, it is expected to return a valid changeset" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert(changeset.valid?)
  end

  test "changeset/1, when attributes are invalid, it is expected to return an invalid changeset" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute(changeset.valid?)
  end

  test "validate_new_balance/3, when it is not a debit operation, it is expected not to add error" do
    current_balance = -2
    limit_amount = 1

    # Isolating for just this validation.
    # Note that this changeset would already be invalid even before this operation.
    changeset =
      %Transaction{}
      |> Changeset.cast(%{amount: 1, type: "c"}, [:amount, :type])
      |> Transaction.validate_new_balance(current_balance, limit_amount)

    assert(changeset.valid?)
  end

  test "validate_new_balance/3, when it is a debit operation and the balance would not exceed the limit, it is expected not add error" do
    current_balance = 0
    limit_amount = 10

    # Isolating for just this validation.
    changeset =
      %Transaction{}
      |> Changeset.cast(%{amount: 1, type: "d"}, [:amount, :type])
      |> Transaction.validate_new_balance(current_balance, limit_amount)

    assert(changeset.valid?)
  end

  test "validate_new_balance/3, when it is a debit operation and the balance would exceed the limit, it is expected add error" do
    current_balance = 0
    limit_amount = 5

    # Isolating for just this validation.
    changeset =
      %Transaction{}
      |> Changeset.cast(%{amount: 6, type: "d"}, [:amount, :type])
      |> Transaction.validate_new_balance(current_balance, limit_amount)

    refute(changeset.valid?)
    assert([balance: {"new balance: -6 exceeded the limit: -5", []}] == changeset.errors)
  end
end
