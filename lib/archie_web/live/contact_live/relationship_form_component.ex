defmodule ArchieWeb.ContactLive.RelationshipFormComponent do
  use ArchieWeb, :live_component
  alias Archie.Contacts
  alias Archie.Contacts.Contact
  alias Archie.Relationships
  alias Archie.Relationships.Relationship

  alias Archie.Contacts

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@new_relationship_form}
        phx-submit="save_relationship"
        phx-change="validate"
        phx-target={@myself}
        id="new-relationship"
        class="hidden"
      >
        <div class="relative my-2">
          <input
            id="combobox"
            name="term"
            phx-target={@myself}
            phx-change="search"
            phx-focus="focus"
            phx-click-away="clear-search"
            type="text"
            value={@selected_contact}
            class="w-full rounded-md border-0 bg-white py-1.5 pl-3 pr-12 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
            role="combobox"
            aria-controls="options"
            aria-expanded="false"
          />
          <button
            type="button"
            class="absolute inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:outline-none"
          >
            <svg
              class="h-5 w-5 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M10 3a.75.75 0 01.55.24l3.25 3.5a.75.75 0 11-1.1 1.02L10 4.852 7.3 7.76a.75.75 0 01-1.1-1.02l3.25-3.5A.75.75 0 0110 3zm-3.76 9.2a.75.75 0 011.06.04l2.7 2.908 2.7-2.908a.75.75 0 111.1 1.02l-3.25 3.5a.75.75 0 01-1.1 0l-3.25-3.5a.75.75 0 01.04-1.06z"
                clip-rule="evenodd"
              />
            </svg>
          </button>

          <ul
            :if={length(@search_results) > 0}
            class="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
            id="options"
            role="listbox"
          >
            <%= for r <- @search_results do %>
              <li
                class="relative cursor-default select-none py-2 pl-3 pr-9 text-gray-900 hover:text-white hover:bg-indigo-600 hover:cursor-pointer"
                role="option"
                tabindex="-1"
                id={"result-#{r.id}"}
                phx-target={@myself}
                phx-click="select-search-result"
                phx-value-id={r.id}
              >
                <span class="block truncate">
                  <%= Contact.display_name(r) %>
                </span>
              </li>
            <% end %>
          </ul>
        </div>
        <.input
          type="select"
          field={@new_relationship_form[:type]}
          value={@new_relationship_form[:type].value}
          label="Type"
          options={Archie.Relationships.Relationship.types()}
        />
        <.input
          type="hidden"
          field={@new_relationship_form[:related_contact_id]}
          value={@new_relationship_form[:related_contact_id].value}
        />

        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    new_relationship =
      Relationships.change_relationship(%Relationship{})

    new_relationship_form = to_form(new_relationship)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:search_results, [])
     |> assign(:selected_contact, nil)
     |> assign(:new_relationship, new_relationship)
     |> assign(:new_relationship_form, new_relationship_form)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save_relationship", %{"relationship" => relationship_attrs} = attrs, socket) do
    relationship_attrs =
      relationship_attrs |> Map.merge(%{"source_contact_id" => socket.assigns.contact.id})

    relationship_attrs =
      if relationship_attrs["related_contact_id"] == "" && attrs["term"] not in ["", nil] do
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

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"relationship" => relationship_params} = params, socket) do
    changeset =
      socket.assigns.new_relationship
      |> Relationship.changeset(relationship_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:new_relationship_form, to_form(changeset))
     |> assign(:selected_contact, params["term"])}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search", %{"term" => term}, socket) when term in ["", nil] do
    results = Contacts.search(term, socket.assigns.contact.id)

    changes =
      Map.put(
        socket.assigns.new_relationship_form.params,
        "related_contact_id",
        nil
      )

    changeset =
      socket.assigns.new_relationship
      |> Relationship.changeset(changes)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:new_relationship_form, to_form(changeset))
     |> assign(:search_results, results)
     |> assign(:selected_contact, term)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search", %{"term" => term}, socket) do
    results = Contacts.search(term, socket.assigns.contact.id)

    {:noreply,
     socket
     |> assign(:search_results, results)
     |> assign(:selected_contact, term)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("focus", _params, socket) do
    results = Contacts.search("", socket.assigns.contact.id)

    {:noreply, assign(socket, :search_results, results)}
  end

  @impl Phoenix.LiveComponent
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
     |> assign(:selected_contact, Contact.display_name(selected_contact))
     |> assign(:new_relationship_form, to_form(changeset))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("clear-search", _params, socket) do
    {:noreply, assign(socket, :search_results, [])}
  end
end
