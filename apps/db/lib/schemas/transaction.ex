defmodule DB.Schemas.Transaction do
  @moduledoc """
    Transactions Schema
  """

  @permitted_params [
    :amount,
    :type,
    :description,
    :customer_id
  ]

  @required_fields [
    :amount,
    :type,
    :description,
    :customer_id
  ]

  use Ecto.Schema

  import Ecto.Changeset

  alias DB.Schemas.Customer

  schema "transactions" do
    field(:description, :string)
    field(:type, Ecto.Enum, values: [:c, :d])
    field(:amount, :integer)

    belongs_to(:customer, Customer)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @permitted_params)
    |> validate_required(@required_fields)
    |> validate_length(:description, min: 1, max: 10)
    |> foreign_key_constraint(:customer_id)
  end

  @doc false
  def validate_new_balance(changeset, balance, limit) do
    validate_change(changeset, :amount, fn :amount, amount ->
      type = get_change(changeset, :type)

      case type == :d && balance - amount < -limit do
        true -> [balance: "new balance: #{balance - amount} exceeded the limit: #{-limit}"]
        false -> []
      end
    end)
  end
end
