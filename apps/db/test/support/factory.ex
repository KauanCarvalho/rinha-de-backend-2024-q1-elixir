defmodule DB.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: DB.Repo

  use DB.Factories.{
    CustomerFactory,
    TransactionFactory
  }
end
