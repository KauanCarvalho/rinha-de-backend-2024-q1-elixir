defmodule DB.Factories.TransactionFactory do
  @moduledoc "Factory for the DB.Schemas.Transaction"

  defmacro __using__(_opts) do
    quote do
      def transaction_factory do
        %DB.Schemas.Transaction{
          amount: 1_000,
          type: "c",
          description: sequence(:title, &"credit-#{&1}"),
          customer: build(:customer)
        }
      end
    end
  end
end
