defmodule BackendFightWeb.CustomerController do
  use BackendFightWeb, :controller

  alias BackendFight.Customers

  def bank_statement(conn, %{"id" => customer_id}) do
    customer_id
    |> Customers.find_for_customer_information()
    |> handle_bank_statement_result(conn)
  end

  defp handle_bank_statement_result({:ok, customer}, conn), do: render(conn, :bank_statement, customer: customer)
  defp handle_bank_statement_result({:error, :not_found}, conn), do: conn |> send_resp(404, "")
  defp handle_bank_statement_result(_, conn), do: conn |> send_resp(422, "")
end
