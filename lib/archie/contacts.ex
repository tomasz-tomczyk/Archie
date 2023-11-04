defmodule Archie.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Archie.Repo

  alias Archie.Contacts.Contact
  alias Archie.Relationships

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts(filters \\ []) do
    from(Contact, where: ^filters)
    |> Repo.all()
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Creates a contact.

  When creating from just a name, the name is split into first and last name. By default, those contacts are also created as secondary.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{})

  def create_contact(attrs) when is_map(attrs) do
    attrs = Contact.reject_empty_nested(attrs)

    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  def create_contact(name) when is_binary(name) do
    String.split(name, " ", trim: true)
    |> case do
      [first_name, last_name] ->
        create_contact(%{first_name: first_name, last_name: last_name, type: :secondary})

      [first_name | rest] ->
        create_contact(%{first_name: first_name, last_name: List.last(rest), type: :secondary})
    end
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    attrs = Contact.reject_empty_nested(attrs)

    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end

  @doc """
  Performs a full-text search for contacts.
  """
  @spec search(String.t() | nil) :: list(Contact.t())
  def search(term \\ nil)

  def search(term) when term in ["", nil] do
    Contact
    |> Repo.all()
  end

  def search(term) do
    from(c in Contact,
      join:
        fts in fragment("SELECT uuid FROM contacts_fts WHERE contacts_fts MATCH ?", ^"#{term}*"),
      on: c.id == fts.uuid
    )
    |> Repo.all()
  end

  @doc """
  Performs a full-text search for contacts, excluding the given contact and its
  relationships.
  """
  @spec search(String.t(), Ecto.UUID.t()) :: list(Contact.t())
  def search(term, excluded_contact_id) when excluded_contact_id in ["", nil] do
    search(term)
  end

  def search(term, excluded_contact_id) when term in ["", nil] do
    Contact
    |> exclude_related(excluded_contact_id)
    |> Repo.all()
  end

  def search(term, excluded_contact_id) do
    from(c in Contact,
      join:
        fts in fragment("SELECT uuid FROM contacts_fts WHERE contacts_fts MATCH ?", ^"#{term}*"),
      on: c.id == fts.uuid
    )
    |> exclude_related(excluded_contact_id)
    |> Repo.all()
  end

  defp exclude_related(query, contact_id) do
    exclude_ids = [contact_id | Relationships.get_related_contact_ids(contact_id)]

    from(c in query, where: c.id not in ^exclude_ids)
  end
end
