defmodule ArchieWeb.ContactLive.SearchComponent do
  @moduledoc false
  use ArchieWeb, :live_component

  alias Archie.Contacts
  alias Archie.Contacts.Contact

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <form phx-target={@myself} phx-change="search" phx-click-away="clear-search">
        <label for="search" class="sr-only">Search</label>
        <div class="relative text-gray-400 focus-within:text-gray-600">
          <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
            <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path
                fill-rule="evenodd"
                d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
          <input
            id="search"
            class="block w-full rounded-md border-0 bg-white py-1.5 pl-10 pr-3 text-gray-900 focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-slate-900 sm:text-sm sm:leading-6"
            placeholder="Search"
            type="search"
            name="term"
            phx-target={@myself}
            phx-focus="focus"
          />
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
      </form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:search_results, [])

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search", %{"term" => term}, socket) do
    results = Contacts.search(term)

    {:noreply, assign(socket, :search_results, results)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("focus", _params, socket) do
    results = Contacts.search()

    {:noreply, assign(socket, :search_results, results)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("clear-search", _params, socket) do
    {:noreply, assign(socket, :search_results, [])}
  end

  @impl Phoenix.LiveComponent
  def handle_event("select-search-result", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/contacts/#{id}")}
  end
end
