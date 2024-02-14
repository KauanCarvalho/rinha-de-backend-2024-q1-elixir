defmodule BackendFightWeb.CustomerJSON do
  alias DB.Schemas.Customer

  @doc false
  def bank_statement(%{customer: %Customer{transactions: transactions} = customer}) do
    %{
      saldo: %{
        total: customer.balance,
        data_extrato: DateTime.utc_now() |> DateTime.to_string(),
        limite: customer.limit_amount
      },
      ultimas_transacoes: transactions |> Enum.map(&transaction_to_json(&1))
    }
  end

  defp transaction_to_json(transaction) do
    %{
      valor: transaction.amount,
      tipo: transaction.type,
      descricao: transaction.description,
      realizada_em: transaction.inserted_at
    }
  end
end
