defmodule Archie.Schema do
  @moduledoc """
  Wrapper around Ecto.Schema for common behaviours we want to our schemas
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]

      @type t :: %__MODULE__{}

      alias __MODULE__
    end
  end
end
