defmodule Archie.Timeline.Note do
  @moduledoc """
  The Note schema.
  """
  use Archie.Schema

  schema "notes" do
    field :body, :string
    belongs_to :contact, Archie.Contacts.Contact

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:body, :contact_id])
    |> validate_required([:body, :contact_id])
  end
end
