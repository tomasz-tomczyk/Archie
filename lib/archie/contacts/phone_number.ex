defmodule Archie.Contacts.PhoneNumber do
  use Archie.Schema

  embedded_schema do
    field :label, :string
    field :value, :string
  end

  def changeset(phone_number, params) do
    phone_number
    |> cast(params, [:label, :value])
  end
end
