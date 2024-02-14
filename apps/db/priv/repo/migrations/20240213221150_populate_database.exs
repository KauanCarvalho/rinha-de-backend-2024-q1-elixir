defmodule DB.Repo.Migrations.PopulateDatabase do
  use Ecto.Migration

  import Ecto.Query, only: [from: 2]

  alias DB.Repo
  alias DB.Schemas.Customer
  alias Ecto.Adapters.SQL

  def change do
    Repo.insert!(%Customer{
      id: 1,
      limit_amount: 1_000 * 100
    })

    Repo.insert!(%Customer{
      id: 2,
      limit_amount: 800 * 100
    })

    Repo.insert!(%Customer{
      id: 3,
      limit_amount: 10_000 * 100
    })

    Repo.insert!(%Customer{
      id: 4,
      limit_amount: 100_000 * 100
    })

    Repo.insert!(%Customer{
      id: 5,
      limit_amount: 5_000 * 100
    })

    SQL.query(Repo, "ALTER SEQUENCE customers_id_seq RESTART WITH 6", [])
  end

  def down do
    from(customer in Customer, where: fragment("? BETWEEN ? AND ?", customer.id, 1, 5))
    |> Repo.delete_all()
  end
end
