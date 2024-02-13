defmodule DB.Factories.CustomerFactory do
  @moduledoc "Factory for the DB.Schemas.Customer"

  defmacro __using__(_opts) do
    quote do
      def customer_factory do
        %DB.Schemas.Customer{
          limit_amount: 10_000,
          balance: 0
        }
      end
    end
  end
end
