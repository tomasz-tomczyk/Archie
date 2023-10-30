defmodule ArchieWeb.ContactLive.Show do
  use ArchieWeb, :live_view

  alias Archie.Contacts
  alias Archie.Contacts.Contact
  alias Archie.Relationships
  alias Archie.Relationships.Relationship

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    contact = Contacts.get_contact!(id)
    relationships = Contact.all_relationships(contact)

    contact_options =
      Contacts.list_contacts() |> Enum.map(fn c -> {Contact.display_name(c), c.id} end)

    new_relationship_form =
      Relationships.change_relationship(%Relationship{}) |> to_form()

    {:noreply,
     socket
     |> assign(:path, "contacts")
     |> assign(:page_title, Contact.display_name(contact))
     |> assign(:contact_options, contact_options)
     |> assign(:contact, contact)
     |> assign(:relationships, relationships)
     |> assign(:new_relationship_form, new_relationship_form)}
  end

  @impl Phoenix.LiveView
  def handle_event("save_relationship", %{"relationship" => relationship_attrs}, socket) do
    attrs = relationship_attrs |> Map.merge(%{"source_contact_id" => socket.assigns.contact.id})

    case Relationships.create_relationship(attrs) do
      {:ok, _relationship} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Relationship saved"))
         |> push_patch(to: "/contacts/#{socket.assigns.contact.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :new_relationship_form, to_form(changeset))}
    end
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
end
