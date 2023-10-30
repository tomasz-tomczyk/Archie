defmodule Utils do
  @moduledoc """
  This module defines adhoc utility functions.
  """

  def map_string_keys(map) do
    Map.new(map, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} -> {key, value}
    end)
  end
end
