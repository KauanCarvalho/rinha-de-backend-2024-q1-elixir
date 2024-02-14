defmodule BackendFightWeb.TransactionJSON do
  alias DB.Schemas.Customer

  @doc false
  def create(%{customer: %Customer{limit_amount: limit_amount, balance: balance}}) do
    %{
      limite: limit_amount,
      saldo: balance
    }
  end
end
