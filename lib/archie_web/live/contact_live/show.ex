defmodule ArchieWeb.ContactLive.Show do
  use ArchieWeb, :live_view

  alias Archie.Contacts
  alias Archie.Contacts.Contact
  alias Archie.Relationships
  alias Archie.Relationships.Relationship

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:search_results, []) |> assign(:selected_contact, nil)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    contact = Contacts.get_contact!(id)
    relationships = Relationships.all_relationships(contact)

    grouped_relationships = Relationships.group_relationships(relationships)

    contact_options =
      Contacts.list_contacts() |> Enum.map(fn c -> {Contact.display_name(c), c.id} end)

    new_relationship =
      Relationships.change_relationship(%Relationship{})

    new_relationship_form = to_form(new_relationship)

    {:noreply,
     socket
     |> assign(:path, "contacts")
     |> assign(:page_title, Contact.display_name(contact))
     |> assign(:contact_options, contact_options)
     |> assign(:contact, contact)
     |> assign(:relationships, grouped_relationships)
     |> assign(:new_relationship, new_relationship)
     |> assign(:new_relationship_form, new_relationship_form)}
  end

  @impl Phoenix.LiveView
  def handle_event("save_relationship", %{"relationship" => relationship_attrs} = attrs, socket) do
    relationship_attrs =
      relationship_attrs |> Map.merge(%{"source_contact_id" => socket.assigns.contact.id})

    relationship_attrs =
      if relationship_attrs["related_contact_id"] == "" do
        {:ok, contact} = Contacts.create_contact(attrs["term"])
        relationship_attrs |> Map.merge(%{"related_contact_id" => contact.id})
      else
        relationship_attrs
      end

    case Relationships.create_relationship(relationship_attrs) do
      {:ok, _relationship} ->
        {:noreply,
         socket
         |> assign(:selected_contact, nil)
         |> put_flash(:info, gettext("Relationship saved"))
         |> push_navigate(to: "/contacts/#{socket.assigns.contact.id}")}

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

  def handle_event("validate", %{"relationship" => relationship_params}, socket) do
    changeset =
      socket.assigns.new_relationship
      |> Relationship.changeset(relationship_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:new_relationship_form, to_form(changeset))}
  end

  def handle_event("search", %{"term" => term}, socket) do
    results = Contacts.search(term, socket.assigns.contact.id)

    {:noreply, socket |> assign(:search_results, results)}
  end

  def handle_event("focus", _params, socket) do
    results = Contacts.search("", socket.assigns.contact.id)

    {:noreply, assign(socket, :search_results, results)}
  end

  def handle_event("select-search-result", %{"id" => id}, socket) do
    selected_contact = Contacts.get_contact!(id)

    changes =
      Map.put(
        socket.assigns.new_relationship_form.params,
        "related_contact_id",
        selected_contact.id
      )

    changeset =
      socket.assigns.new_relationship
      |> Relationship.changeset(changes)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:selected_contact, selected_contact)
     |> assign(:new_relationship_form, to_form(changeset))}
  end

  def handle_event("clear-search", _params, socket) do
    {:noreply, assign(socket, :search_results, [])}
  end
end
