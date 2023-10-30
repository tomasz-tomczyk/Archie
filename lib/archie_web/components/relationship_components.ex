defmodule ArchieWeb.RelationshipComponents do
  @moduledoc """
  A module providing components for relationships.
  """
  use Phoenix.Component

  alias Archie.Relationships.Relationship

  @relationships_classes %{
    :spouse => "bg-pink-50 text-pink-700 ring-pink-700/10",
    :partner => "bg-pink-50 text-pink-700 ring-pink-700/10",
    :sibling => "bg-yellow-50 text-yellow-700 ring-yellow-700/10",
    :child => "bg-pink-50 text-pink-700 ring-pink-700/10",
    :cousin => "bg-yellow-50 text-yellow-700 ring-yellow-700/10",
    :parent => "bg-yellow-50 text-yellow-700 ring-yellow-700/10",
    :friend => "bg-green-50 text-green-700 ring-green-700/10"
  }

  attr :type, :string,
    default: "friend",
    values: Map.values(Relationship.types())

  attr :class, :string, default: nil

  def relation(assigns) do
    classes = @relationships_classes[assigns.type]

    label =
      Relationship.types() |> Enum.find(fn {_, v} -> v == to_string(assigns.type) end) |> elem(0)

    assigns =
      assigns
      |> assign(:label, label)
      |> assign(:classes, classes)

    ~H"""
    <span class={[
      @classes,
      "inline-flex items-center rounded-full px-2 py-1 text-xs font-medium ring-1 ring-inset",
      @class
    ]}>
      <%= @label %>
    </span>
    """
  end
end
