defmodule Archie.TimelineTest do
  use Archie.DataCase, async: true

  alias Archie.Timeline

  describe "notes" do
    alias Archie.Timeline.Note

    import Archie.TimelineFixtures
    import Archie.ContactsFixtures

    @invalid_attrs %{body: nil}

    test "list_notes/0 returns all notes" do
      note = note_fixture()
      assert Timeline.list_notes() == [note]
    end

    test "get_note!/1 returns the note with given id" do
      note = note_fixture()
      assert Timeline.get_note!(note.id) == note
    end

    test "create_note/1 with valid data creates a note" do
      contact = contact_fixture()
      valid_attrs = %{contact_id: contact.id, body: "some body"}

      assert {:ok, %Note{} = note} = Timeline.create_note(valid_attrs)
      assert note.body == "some body"
    end

    test "create_note/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_note(@invalid_attrs)
    end

    test "update_note/2 with valid data updates the note" do
      note = note_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Note{} = note} = Timeline.update_note(note, update_attrs)
      assert note.body == "some updated body"
    end

    test "update_note/2 with invalid data returns error changeset" do
      note = note_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_note(note, @invalid_attrs)
      assert note == Timeline.get_note!(note.id)
    end

    test "delete_note/1 deletes the note" do
      note = note_fixture()
      assert {:ok, %Note{}} = Timeline.delete_note(note)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_note!(note.id) end
    end

    test "change_note/1 returns a note changeset" do
      note = note_fixture()
      assert %Ecto.Changeset{} = Timeline.change_note(note)
    end
  end
end
