defmodule Archie.Repo.Migrations.CreateRelationships do
  use Ecto.Migration

  def change do
    create table(:relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string

      add :source_contact_id,
          references(:contacts, on_delete: :delete_all, type: :binary_id, null: false)

      add :related_contact_id,
          references(:contacts, on_delete: :delete_all, type: :binary_id, null: true)

      timestamps()
    end

    create index(:relationships, [:source_contact_id])
    create index(:relationships, [:related_contact_id])
  end
end
