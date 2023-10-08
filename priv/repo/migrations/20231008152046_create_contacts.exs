defmodule Archie.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :dob, :date
      add :emails, :map
      add :phone_numbers, :map

      timestamps()
    end
  end
end
