defmodule Archie.RelationshipsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Archie.Relationships` context.
  """

  import Archie.ContactsFixtures

  @doc """
  Generate a relationship.
  """
  def relationship_fixture(attrs \\ %{}) do
    source_contact = attrs[:source_contact] || contact_fixture()

    {:ok, relationship} =
      attrs
      |> Enum.into(%{
        name: "some name",
        type: :friend,
        source_contact_id: source_contact.id
      })
      |> Archie.Relationships.create_relationship()

    relationship
  end
end
