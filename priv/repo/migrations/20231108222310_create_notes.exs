defmodule Archie.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :string
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:notes, [:contact_id])
  end
end
