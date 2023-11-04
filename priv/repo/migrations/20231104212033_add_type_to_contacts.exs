defmodule Archie.Repo.Migrations.AddTypeToContacts do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      add :type, :string, default: "primary"
    end
  end
end
