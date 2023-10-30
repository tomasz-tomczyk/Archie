defmodule Archie.Relationships do
  @moduledoc """
  The Relationships context.
  """

  import Ecto.Query, warn: false
  alias Archie.Repo

  alias Archie.Relationships.Relationship

  @doc """
  Returns the list of relationships.

  ## Examples

      iex> list_relationships()
      [%Relationship{}, ...]

  """
  def list_relationships do
    Repo.all(Relationship)
  end

  @doc """
  Gets a single relationship.

  Raises `Ecto.NoResultsError` if the Relationship does not exist.

  ## Examples

      iex> get_relationship!(123)
      %Relationship{}

      iex> get_relationship!(456)
      ** (Ecto.NoResultsError)

  """
  def get_relationship!(id), do: Repo.get!(Relationship, id)

  @doc """
  Creates a relationship.

  ## Examples

      iex> create_relationship(%{field: value})
      {:ok, %Relationship{}}

      iex> create_relationship(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_relationship(attrs \\ %{}) do
    %Relationship{}
    |> Relationship.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a relationship.

  ## Examples

      iex> update_relationship(relationship, %{field: new_value})
      {:ok, %Relationship{}}

      iex> update_relationship(relationship, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_relationship(%Relationship{} = relationship, attrs) do
    relationship
    |> Relationship.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a relationship.

  ## Examples

      iex> delete_relationship(relationship)
      {:ok, %Relationship{}}

      iex> delete_relationship(relationship)
      {:error, %Ecto.Changeset{}}

  """
  def delete_relationship(%Relationship{} = relationship) do
    Repo.delete(relationship)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking relationship changes.

  ## Examples

      iex> change_relationship(relationship)
      %Ecto.Changeset{data: %Relationship{}}

  """
  def change_relationship(%Relationship{} = relationship, attrs \\ %{}) do
    Relationship.changeset(relationship, attrs)
  end

  def all_relationships(contact) do
    contact =
      Repo.preload(contact,
        source_relationships: [:related_contact],
        related_relationships: [:source_contact]
      )

    source_relationships =
      contact.source_relationships |> Enum.map(fn r -> %{r | contact: r.related_contact} end)

    related_relationships =
      contact.related_relationships
      |> Enum.map(fn r ->
        %{r | contact: r.source_contact, type: inverse_relationship(r.type)}
      end)

    source_relationships ++ related_relationships
  end

  defp inverse_relationship(:parent), do: :child
  defp inverse_relationship(:child), do: :parent
  defp inverse_relationship(type), do: type
end
