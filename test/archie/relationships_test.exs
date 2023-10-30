defmodule Archie.RelationshipsTest do
  use Archie.DataCase, async: true

  alias Archie.Relationships

  describe "relationships" do
    alias Archie.Relationships.Relationship

    import Archie.RelationshipsFixtures
    import Archie.ContactsFixtures

    @invalid_attrs %{name: nil, type: nil}

    test "list_relationships/0 returns all relationships" do
      relationship = relationship_fixture()
      assert Relationships.list_relationships() == [relationship]
    end

    test "get_relationship!/1 returns the relationship with given id" do
      relationship = relationship_fixture()
      assert Relationships.get_relationship!(relationship.id) == relationship
    end

    test "create_relationship/1 with valid data creates a relationship" do
      contact = contact_fixture()
      valid_attrs = %{name: "some name", type: :friend, source_contact_id: contact.id}

      assert {:ok, %Relationship{} = relationship} =
               Relationships.create_relationship(valid_attrs)

      assert relationship.name == "some name"
      assert relationship.type == :friend
    end

    test "create_relationship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Relationships.create_relationship(@invalid_attrs)
    end

    test "update_relationship/2 with valid data updates the relationship" do
      relationship = relationship_fixture()
      update_attrs = %{name: "some updated name", type: :spouse}

      assert {:ok, %Relationship{} = relationship} =
               Relationships.update_relationship(relationship, update_attrs)

      assert relationship.name == "some updated name"
      assert relationship.type == :spouse
    end

    test "update_relationship/2 with invalid data returns error changeset" do
      relationship = relationship_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Relationships.update_relationship(relationship, @invalid_attrs)

      assert relationship == Relationships.get_relationship!(relationship.id)
    end

    test "delete_relationship/1 deletes the relationship" do
      relationship = relationship_fixture()
      assert {:ok, %Relationship{}} = Relationships.delete_relationship(relationship)
      assert_raise Ecto.NoResultsError, fn -> Relationships.get_relationship!(relationship.id) end
    end

    test "change_relationship/1 returns a relationship changeset" do
      relationship = relationship_fixture()
      assert %Ecto.Changeset{} = Relationships.change_relationship(relationship)
    end
  end
end
