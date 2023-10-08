defmodule Archie.ContactsTest do
  use Archie.DataCase

  alias Archie.Contacts

  describe "contacts" do
    alias Archie.Contacts.Contact

    import Archie.ContactsFixtures

    @invalid_attrs %{dob: nil, emails: nil, first_name: nil, last_name: nil, phone_numbers: nil}

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      valid_attrs = %{dob: ~D[2023-10-07], emails: %{}, first_name: "some first_name", last_name: "some last_name", phone_numbers: %{}}

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.dob == ~D[2023-10-07]
      assert contact.emails == %{}
      assert contact.first_name == "some first_name"
      assert contact.last_name == "some last_name"
      assert contact.phone_numbers == %{}
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      update_attrs = %{dob: ~D[2023-10-08], emails: %{}, first_name: "some updated first_name", last_name: "some updated last_name", phone_numbers: %{}}

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, update_attrs)
      assert contact.dob == ~D[2023-10-08]
      assert contact.emails == %{}
      assert contact.first_name == "some updated first_name"
      assert contact.last_name == "some updated last_name"
      assert contact.phone_numbers == %{}
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end
end
