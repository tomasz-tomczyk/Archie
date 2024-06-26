defmodule Archie.Contacts.Contact do
  @moduledoc """
  A contact. The main model in the application.
  """
  use Archie.Schema

  alias Archie.Contacts.Email
  alias Archie.Contacts.PhoneNumber
  alias Archie.Relationships.Relationship

  schema "contacts" do
    field :dob, :date
    field :first_name, :string
    field :last_name, :string

    field(:type, Ecto.Enum, values: [:primary, :secondary], default: :primary)

    embeds_many :emails, Email, on_replace: :delete
    embeds_many :phone_numbers, PhoneNumber, on_replace: :delete

    has_many :source_relationships, Relationship, foreign_key: :source_contact_id
    has_many :related_relationships, Relationship, foreign_key: :related_contact_id

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:first_name, :last_name, :dob, :type])
    |> validate_required([:first_name, :type])
    |> cast_embed(:emails,
      with: &Email.changeset/2,
      sort_param: :emails_sort,
      drop_param: :emails_drop
    )
    |> cast_embed(:phone_numbers,
      with: &PhoneNumber.changeset/2,
      sort_param: :phone_numbers_sort,
      drop_param: :phone_numbers_drop
    )
  end

  @doc """
  Ensures that empty emails and phone numbers get flagged for deletion.
  """
  def reject_empty_nested(attrs) do
    attrs
    |> Utils.map_string_keys()
    |> Map.update("emails_drop", [""], fn emails_drop ->
      emails_drop ++ find_empty_nested(Map.get(attrs, "emails"))
    end)
    |> Map.update("phone_numbers_drop", [""], fn phone_numbers_drop ->
      phone_numbers_drop ++ find_empty_nested(Map.get(attrs, "phone_numbers"))
    end)
  end

  defp find_empty_nested(nil), do: []

  defp find_empty_nested(map) do
    map
    |> Enum.map(fn {key, value} ->
      case value do
        %{"value" => nil} -> key
        %{"value" => ""} -> key
        _other -> false
      end
    end)
    |> Enum.reject(&(&1 == false))
  end

  def display_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    [first_name, last_name]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  def display_name(_contact), do: ""
end
