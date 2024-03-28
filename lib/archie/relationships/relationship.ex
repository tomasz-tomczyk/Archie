defmodule Archie.Relationships.Relationship do
  @moduledoc """
  A relationship between two contacts.
  """
  use Archie.Schema

  import ArchieWeb.Gettext

  @types ~w(spouse partner sibling child cousin parent friend)a

  schema "relationships" do
    field(:type, Ecto.Enum, values: @types, default: :friend)

    belongs_to :source_contact, Archie.Contacts.Contact
    belongs_to :related_contact, Archie.Contacts.Contact

    field :contact, :map, virtual: true

    timestamps()
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:type, :source_contact_id, :related_contact_id])
    |> validate_required([:type, :source_contact_id, :related_contact_id])
    |> validate_no_reverse_relationship()
    |> unique_constraint([:source_contact_id, :related_contact_id],
      name: :relationships_source_contact_id_related_contact_id_index,
      message: gettext("has this relationship already")
    )
  end

  defp validate_no_reverse_relationship(changeset) do
    source_contact_id = get_field(changeset, :source_contact_id)
    related_contact_id = get_field(changeset, :related_contact_id)

    if source_contact_id == nil or related_contact_id == nil do
      changeset
    else
      if Repo.get_by(__MODULE__,
           source_contact_id: related_contact_id,
           related_contact_id: source_contact_id
         ) do
        add_error(changeset, :related_contact_id, gettext("has this relationship already"))
      else
        changeset
      end
    end
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
