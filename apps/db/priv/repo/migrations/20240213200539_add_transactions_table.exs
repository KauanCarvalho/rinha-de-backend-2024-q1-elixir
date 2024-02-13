defmodule DB.Repo.Migrations.AddTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:amount, :integer)
      add(:type, :char)
      add(:description, :string, size: 10)
      add(:customer_id, references(:customers, on_delete: :nothing))

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create(index(:transactions, [:customer_id]))
  end
end
