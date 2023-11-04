defmodule ArchieWeb.ContactLive.Show do
  use ArchieWeb, :live_view

  alias Archie.Contacts
  alias Archie.Contacts.Contact
  alias Archie.Relationships

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    contact = Contacts.get_contact!(id)
    relationships = Relationships.all_relationships(contact)

    grouped_relationships = Relationships.group_relationships(relationships)

    contact_options =
      Contacts.list_contacts() |> Enum.map(fn c -> {Contact.display_name(c), c.id} end)

    {:noreply,
     socket
     |> assign(:path, "contacts")
     |> assign(:page_title, Contact.display_name(contact))
     |> assign(:contact_options, contact_options)
     |> assign(:contact, contact)
     |> assign(:relationships, grouped_relationships)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete_relationship", %{"id" => relationship_id}, socket) do
    relationship = Relationships.get_relationship!(relationship_id)

    case Relationships.delete_relationship(relationship) do
      {:ok, _relationship} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Relationship deleted"))
         |> push_patch(to: "/contacts/#{socket.assigns.contact.id}")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Could not delete the relationship"))
         |> push_patch(to: "/contacts/#{socket.assigns.contact.id}")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-type", _params, socket) do
    type = if socket.assigns.contact.type == :primary, do: :secondary, else: :primary

    {:ok, contact} =
      Contacts.update_contact(socket.assigns.contact, %{type: type})

    {:noreply,
     socket
     |> assign(:contact, contact)}
  end
end
