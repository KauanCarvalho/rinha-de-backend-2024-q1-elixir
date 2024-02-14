defmodule BackendFightWeb.TransactionController do
  use BackendFightWeb, :controller

  alias BackendFight.Customers

  def create(conn, %{"id" => customer_id} = params) do
    attrs = %{
      amount: params["valor"],
      type: params["tipo"],
      description: params["descricao"]
    }

    attrs
    |> Customers.create_transaction_and_refresh_balance(customer_id)
    |> handle_create_result_result(conn)
  end

  defp handle_create_result_result({:ok, %{customer_updated: customer_updated}}, conn),
    do: render(conn, :create, customer: customer_updated)

  defp handle_create_result_result({:error, :locked_customer, :not_found, _}, conn), do: conn |> send_resp(404, "")
  defp handle_create_result_result({:error, :invalid_customer_id}, conn), do: conn |> send_resp(422, "")
  defp handle_create_result_result(_, conn), do: conn |> send_resp(422, "")
end
