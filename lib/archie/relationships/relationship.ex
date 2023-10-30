defmodule Archie.Relationships.Relationship do
  use Archie.Schema

  schema "relationships" do
    field :name, :string
    field :type, :string

    belongs_to :source_contact, Archie.Contacts.Contact
    belongs_to :related_contact, Archie.Contacts.Contact

    timestamps()
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:name, :type, :source_contact_id, :related_contact_id])
    |> validate_required([:type, :source_contact_id])
  end
end
