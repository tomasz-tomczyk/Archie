defmodule Archie.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Archie.Contacts` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    {:ok, contact} =
      attrs
      |> Enum.into(%{
        dob: ~D[2023-10-07],
        emails: %{},
        first_name: "some first_name",
        last_name: "some last_name",
        phone_numbers: %{}
      })
      |> Archie.Contacts.create_contact()

    contact
  end
end
