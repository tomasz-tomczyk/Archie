defmodule Archie.Contacts.Email do
  use Archie.Schema

  embedded_schema do
    field :label, :string
    field :value, :string
  end

  def changeset(email, params) do
    email
    |> cast(params, [:label, :value])
  end
end
