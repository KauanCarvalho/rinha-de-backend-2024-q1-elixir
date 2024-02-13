defmodule DB.Schemas.Customer do
  @moduledoc """
    Customers Schema
  """

  @permitted_params [
    :limit_amount,
    :balance
  ]

  @required_fields [
    :limit_amount
  ]

  use Ecto.Schema

  import Ecto.Changeset

  schema "customers" do
    field(:limit_amount, :integer)
    field(:balance, :integer, default: 0)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @permitted_params)
    |> validate_required(@required_fields)
  end
end
