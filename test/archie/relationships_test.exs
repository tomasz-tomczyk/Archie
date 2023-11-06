defmodule Archie.RelationshipsTest do
  use Archie.DataCase, async: false
  import Archie.ContactsFixtures
  import Archie.RelationshipsFixtures

  alias Archie.Relationships
  alias Archie.Relationships.Relationship

  describe "relationships" do
    @invalid_attrs %{type: nil}

    test "list_relationships/0 returns all relationships" do
      relationship = relationship_fixture()
      assert Relationships.list_relationships() == [relationship]
    end

    test "get_relationship!/1 returns the relationship with given id" do
      relationship = relationship_fixture()
      assert Relationships.get_relationship!(relationship.id) == relationship
    end

    test "create_relationship/1 with valid data creates a relationship" do
      source_contact = contact_fixture()
      related_contact = contact_fixture()

      valid_attrs = %{
        type: :friend,
        source_contact_id: source_contact.id,
        related_contact_id: related_contact.id
      }

      assert {:ok, %Relationship{} = relationship} =
               Relationships.create_relationship(valid_attrs)

      assert relationship.type == :friend
    end

    test "create_relationship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Relationships.create_relationship(@invalid_attrs)
    end

    test "create_relationship/1 does not allow creating a duplicate relationship" do
      relationship = relationship_fixture()

      new_relationship = %{
        source_contact_id: relationship.source_contact_id,
        related_contact_id: relationship.related_contact_id
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [source_contact_id: {"has this relationship already", _details}]
              }} =
               Relationships.create_relationship(new_relationship)
    end

    test "create_relationship/1 does not allow creating an inverse relationship" do
      relationship = relationship_fixture()

      new_relationship = %{
        source_contact_id: relationship.related_contact_id,
        related_contact_id: relationship.source_contact_id
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [related_contact_id: {"has this relationship already", _details}]
              }} =
               Relationships.create_relationship(new_relationship)
    end

    test "update_relationship/2 with valid data updates the relationship" do
      relationship = relationship_fixture()
      update_attrs = %{type: :spouse}

      assert {:ok, %Relationship{} = relationship} =
               Relationships.update_relationship(relationship, update_attrs)

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

  describe "group_relationships/1" do
    test "returns grouped relationships" do
      %{id: source_contact_id} = source_contact = contact_fixture()

      _friend = relationship_fixture(source_contact: source_contact, type: :friend)
      _spouse = relationship_fixture(source_contact: source_contact, type: :spouse)

      assert %{
               family: [
                 %Relationship{
                   source_contact_id: ^source_contact_id,
                   type: :spouse
                 }
               ],
               other: [
                 %Relationship{
                   source_contact_id: ^source_contact_id,
                   type: :friend
                 }
               ]
             } =
               Relationships.all_relationships(source_contact)
               |> Relationships.group_relationships()
    end

    test "returns family in the priority order" do
      source_contact = contact_fixture()

      relationship_fixture(source_contact: source_contact, type: :cousin)
      relationship_fixture(source_contact: source_contact, type: :sibling)
      relationship_fixture(source_contact: source_contact, type: :parent)
      relationship_fixture(source_contact: source_contact, type: :child)
      relationship_fixture(source_contact: source_contact, type: :spouse)
      relationship_fixture(source_contact: source_contact, type: :partner)

      assert Relationships.all_relationships(source_contact)
             |> Relationships.group_relationships()
             |> Map.get(:family, [])
             |> Enum.map(& &1.type) == [:spouse, :partner, :child, :sibling, :parent, :cousin]
    end

    test "for parent <-> child relationship, from child parent perspective, the relationship is a parent" do
      parent = contact_fixture(first_name: "John")
      child = contact_fixture(first_name: "Jane")

      _relationship =
        relationship_fixture(source_contact: parent, related_contact: child, type: :child)

      [r] =
        Relationships.all_relationships(child)

      assert r.type == :parent
    end

    test "for child <-> parent relationship, from the parent perspective, the relationship is a child" do
      parent = contact_fixture(first_name: "John")
      child = contact_fixture(first_name: "Jane")

      _relationship =
        relationship_fixture(source_contact: child, related_contact: parent, type: :parent)

      [r] =
        Relationships.all_relationships(parent)

      assert r.type == :child
    end

    test "does not invert a relationship that isn't parent or child" do
      person = contact_fixture(first_name: "John")
      friend = contact_fixture(first_name: "Jane")

      _relationship =
        relationship_fixture(source_contact: friend, related_contact: person, type: :friend)

      [r] =
        Relationships.all_relationships(person)

      assert r.type == :friend
    end
  end
end
