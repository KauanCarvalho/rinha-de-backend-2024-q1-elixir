defmodule DB.Schemas.CustomerTest do
  use DB.DataCase

  alias DB.Schemas.Customer

  @valid_attrs %{limit_amount: 1_000, balance: 0}
  @invalid_attrs %{limit_amount: nil, balance: nil}

  test "changeset/1, when attributes are valid, it is expected to return a valid changeset" do
    changeset = Customer.changeset(%Customer{}, @valid_attrs)
    assert(changeset.valid?)
  end

  test "changeset/1, when attributes are invalid, it is expected to return an invalid changeset" do
    changeset = Customer.changeset(%Customer{}, @invalid_attrs)
    refute(changeset.valid?)
  end
end
