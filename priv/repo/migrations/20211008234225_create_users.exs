defmodule Drag.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :position, :integer, null: true

      timestamps()
    end

    create unique_index(:users, [:position])
  end
end
