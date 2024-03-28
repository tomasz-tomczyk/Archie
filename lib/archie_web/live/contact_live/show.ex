defmodule ArchieWeb.ContactLive.Show do
  @moduledoc false
  use ArchieWeb, :live_view

  alias Archie.Contacts
  alias Archie.Contacts.Contact
  alias Archie.Relationships
  alias Archie.Timeline
  alias Archie.Timeline.Note

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
      Enum.map(Contacts.list_contacts(), fn c -> {Contact.display_name(c), c.id} end)

    note = %Note{contact_id: contact.id}

    {:noreply,
     socket
     |> assign(:path, "contacts")
     |> assign(:page_title, Contact.display_name(contact))
     |> assign(:contact_options, contact_options)
     |> assign(:contact, contact)
     |> assign(:relationships, grouped_relationships)
     |> assign(:note, note)
     |> assign_notes()}
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

    {:noreply, assign(socket, :contact, contact)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete_note", %{"id" => id}, socket) do
    note = Timeline.get_note!(id)
    {:ok, _} = Timeline.delete_note(note)

    {:noreply, assign_notes(socket)}
  end

  defp assign_notes(socket) do
    notes = Timeline.list_notes(contact_id: socket.assigns.contact.id)
    notes_count = length(notes)

    socket
    |> assign(:notes, notes)
    |> assign(:notes_count, notes_count)
  end
end
