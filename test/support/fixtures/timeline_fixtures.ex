defmodule Archie.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Archie.Timeline` context.
  """
  import Archie.ContactsFixtures

  @doc """
  Generate a note.
  """
  def note_fixture(attrs \\ %{}) do
    contact = attrs[:contact] || contact_fixture()

    {:ok, note} =
      attrs
      |> Enum.into(%{
        contact_id: contact.id,
        body: "some body"
      })
      |> Archie.Timeline.create_note()

    note
  end
end
