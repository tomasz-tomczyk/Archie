defmodule Archie.Relationships.Relationship do
  @moduledoc """
  A relationship between two contacts.
  """
  use Archie.Schema
  import ArchieWeb.Gettext

  @types ~w(spouse partner sibling child cousin parent friend)a

  schema "relationships" do
    field :name, :string
    field(:type, Ecto.Enum, values: @types, default: :friend)

    belongs_to :source_contact, Archie.Contacts.Contact
    belongs_to :related_contact, Archie.Contacts.Contact

    field :contact, :map, virtual: true

    timestamps()
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:name, :type, :source_contact_id, :related_contact_id])
    |> validate_required([:type, :source_contact_id])
  end

  def types do
    %{
      gettext("Spouse") => "spouse",
      gettext("Partner") => "partner",
      gettext("Sibling") => "sibling",
      gettext("Child") => "child",
      gettext("Cousin") => "cousin",
      gettext("Parent") => "parent",
      gettext("Friend") => "friend"
    }
  end
end
