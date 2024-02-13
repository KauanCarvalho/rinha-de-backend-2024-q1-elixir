defmodule DB.Repo.Migrations.AddCustomersTable do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add(:limit_amount, :integer, null: false)
      add(:balance, :integer, default: 0)
    end
  end
end
