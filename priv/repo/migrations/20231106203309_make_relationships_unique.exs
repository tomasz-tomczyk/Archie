defmodule Archie.Repo.Migrations.MakeRelationshipsUnique do
  use Ecto.Migration

  def change do
    create unique_index(:relationships, [:source_contact_id, :related_contact_id])
  end
end
