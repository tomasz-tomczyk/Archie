defmodule Archie.Repo.Migrations.AddFtsForContacts do
  use Ecto.Migration
  alias Archie.Repo

  def up do
    Ecto.Adapters.SQL.query!(Repo, """
    CREATE VIRTUAL TABLE contacts_fts USING fts5(uuid UNINDEXED, first_name, last_name);
    """)

    # Backfill data
    Ecto.Adapters.SQL.query!(Repo, """
    INSERT INTO contacts_fts (uuid, first_name, last_name)
    SELECT id, first_name, last_name FROM contacts;
    """)

    # Trigger for INSERT
    Ecto.Adapters.SQL.query!(Repo, """
    CREATE TRIGGER contacts_ai AFTER INSERT ON contacts BEGIN
      INSERT INTO contacts_fts (uuid, first_name, last_name) VALUES (new.id, new.first_name, new.last_name);
    END;
    """)

    # Trigger for UPDATE
    Ecto.Adapters.SQL.query!(Repo, """
    CREATE TRIGGER contacts_au AFTER UPDATE ON contacts BEGIN
      DELETE FROM contacts_fts WHERE uuid = old.id;
      INSERT INTO contacts_fts (uuid, first_name, last_name) VALUES(new.id, new.first_name, new.last_name);
    END;
    """)

    # Trigger for DELETE
    Ecto.Adapters.SQL.query!(Repo, """
    CREATE TRIGGER contacts_ad AFTER DELETE ON contacts BEGIN
      DELETE FROM contacts_fts WHERE uuid = old.id;
    END;
    """)
  end

  def down do
    # Drop the FTS table
    Ecto.Adapters.SQL.query!(Repo, """
    DROP TABLE IF EXISTS contacts_fts;
    """)

    # Drop the triggers
    Ecto.Adapters.SQL.query!(Repo, """
    DROP TRIGGER IF EXISTS contacts_ai;
    """)

    Ecto.Adapters.SQL.query!(Repo, """
    DROP TRIGGER IF EXISTS contacts_au;
    """)

    Ecto.Adapters.SQL.query!(Repo, """
    DROP TRIGGER IF EXISTS contacts_ad;
    """)
  end
end
