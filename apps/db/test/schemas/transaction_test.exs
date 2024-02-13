defmodule DB.Schemas.TransactionTest do
  use DB.DataCase

  import DB.Factory

  alias DB.Schemas.Transaction

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
end
