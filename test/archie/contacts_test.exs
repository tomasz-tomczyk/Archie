defmodule Archie.ContactsTest do
  use Archie.DataCase, async: false
  import Archie.ContactsFixtures
  import Archie.RelationshipsFixtures

  alias Archie.Contacts
  alias Archie.Contacts.Contact

  describe "contacts" do
    @invalid_attrs %{
      "dob" => nil,
      "emails" => nil,
      "first_name" => nil,
      "last_name" => nil,
      "phone_numbers" => nil
    }

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      valid_attrs = %{
        "dob" => ~D[2023-10-07],
        "first_name" => "John",
        "last_name" => "Doe"
      }

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.dob == ~D[2023-10-07]
      assert contact.emails == []
      assert contact.first_name == "John"
      assert contact.last_name == "Doe"
      assert contact.phone_numbers == []
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "create_contact/1 with no data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact()
    end

    test "create_contact/1 with just the name creates a contact" do
      assert {:ok, %Contact{} = contact} = Contacts.create_contact("John Doe")
      assert contact.first_name == "John"
      assert contact.last_name == "Doe"

      assert {:ok, %Contact{} = contact} = Contacts.create_contact("Jonny")
      assert contact.first_name == "Jonny"
      assert contact.last_name == nil

      assert {:ok, %Contact{} = contact} = Contacts.create_contact("Jonny Don Doe")
      assert contact.first_name == "Jonny"
      assert contact.last_name == "Doe"
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()

      update_attrs = %{
        "dob" => ~D[2023-10-08],
        "emails" => %{},
        "first_name" => "some updated first_name",
        "last_name" => "some updated last_name",
        "phone_numbers" => %{}
      }

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, update_attrs)
      assert contact.dob == ~D[2023-10-08]
      assert contact.emails == []
      assert contact.first_name == "some updated first_name"
      assert contact.last_name == "some updated last_name"
      assert contact.phone_numbers == []
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

  describe "search/1" do
    test "returns all contacts when given empty search term" do
      contact = contact_fixture()
      assert Contacts.search("") == [contact]
      assert Contacts.search(nil) == [contact]
    end

    test "returns matching contacts when given non-empty term " do
      contact = contact_fixture(first_name: "Tomasz", last_name: "Tomczyk")
      assert Contacts.search("test") == []
      assert Contacts.search("asz") == []
      assert Contacts.search("Tom") == [contact]
      assert Contacts.search("Tomczyk") == [contact]
      assert Contacts.search("Tomasz") == [contact]
    end
  end

  describe "search/2" do
    test "returns all contacts when given empty term and no id to exclude" do
      contact = contact_fixture()
      assert Contacts.search("", nil) == [contact]
      assert Contacts.search(nil, nil) == [contact]
    end

    test "returns all contacts except the excluded one when given empty term and id to exclude" do
      kept_contact = contact_fixture()
      excluded_contact = contact_fixture()
      assert Contacts.search("", excluded_contact.id) == [kept_contact]
      assert Contacts.search(nil, excluded_contact.id) == [kept_contact]
    end

    test "returns matching contacts when given non-empty term and no id to exclude" do
      contact = contact_fixture(first_name: "Tomasz", last_name: "Tomczyk")
      assert Contacts.search("Tom", nil) == [contact]
    end

    test "returns matching contacts except the excluded one when given non-empty term and id to exclude" do
      kept_contact = contact_fixture(first_name: "Tomasz", last_name: "Tomczyk")
      excluded_contact = contact_fixture()
      assert Contacts.search("Tom", excluded_contact.id) == [kept_contact]
    end

    test "returns matching contacts except the excluded one and its relationships" do
      kept_contact = contact_fixture(first_name: "John")
      excluded_contact = contact_fixture()
      related_contact = contact_fixture(first_name: "John")

      _relationship =
        relationship_fixture(source_contact: excluded_contact, related_contact: related_contact)

      assert Contacts.search("John", excluded_contact.id) == [kept_contact]
      assert Contacts.search("", excluded_contact.id) == [kept_contact]
    end
  end
end
