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
        dob: ~D[1990-01-01],
        emails: %{},
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        phone_numbers: [%{label: "personal", value: Faker.Phone.EnGb.number()}]
      })
      |> Archie.Contacts.create_contact()

    contact
  end
end
