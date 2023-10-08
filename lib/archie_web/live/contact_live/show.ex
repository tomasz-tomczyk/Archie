defmodule ArchieWeb.ContactLive.Show do
  use ArchieWeb, :live_view

  alias Archie.Contacts
  alias Archie.Contacts.Contact

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _uri, socket) do
    contact = Contacts.get_contact!(id)

    {:noreply,
     socket
     |> assign(:path, "contacts")
     |> assign(:page_title, Contact.display_name(contact))
     |> assign(:contact, contact)}
  end
end
