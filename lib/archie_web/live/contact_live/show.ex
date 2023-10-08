defmodule ArchieWeb.ContactLive.Show do
  use ArchieWeb, :live_view

  alias Archie.Contacts
  alias Archie.Contacts.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact = Contacts.get_contact!(id)

    {:noreply,
     socket
     |> assign(:page_title, Contact.display_name(contact))
     |> assign(:contact, contact)}
  end
end
