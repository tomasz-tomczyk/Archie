defmodule ArchieWeb.ContactLive.FormComponent do
  @moduledoc false
  use ArchieWeb, :live_component

  alias Archie.Contacts

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="contact-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6">
          <div class="sm:col-span-3">
            <.input field={@form[:first_name]} type="text" label="First name" />
          </div>
          <div class="sm:col-span-3">
            <.input field={@form[:last_name]} type="text" label="Last name" />
          </div>
        </div>
        <div class="grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6 mt-4">
          <div class="sm:col-span-3">
            <.input field={@form[:dob]} type="date" label="Date of Birth" />
          </div>
          <div class="sm:col-span-3"></div>
        </div>

        <div class="grid grid-cols-1 gap-2 sm:grid-cols-6 mt-4">
          <.inputs_for :let={f_pn} field={@form[:phone_numbers]}>
            <div class="sm:col-span-2">
              <.input type="hidden" name="contact[phone_numbers_sort][]" value={f_pn.index} />
              <.input
                field={f_pn[:label]}
                type="select"
                options={Archie.Contacts.PhoneNumber.types()}
              />
            </div>
            <div class="sm:col-span-3">
              <.input field={f_pn[:value]} type="text" />
            </div>
            <label class="sm:col-span-1">
              <input
                type="checkbox"
                name="contact[phone_numbers_drop][]"
                value={f_pn.index}
                class="hidden"
              />
              <.icon
                name="hero-minus-circle"
                class="w-5 h-5 text-amber-600 hover:text-amber-500 mt-5 relative cursor-pointer"
              />
            </label>
          </.inputs_for>
        </div>

        <input type="hidden" name="contact[phone_numbers_drop][]" class="hidden" />

        <label class="block cursor-pointer my-2 mb-4">
          <input type="checkbox" name="contact[phone_numbers_sort][]" class="hidden" />
          <span
            type="button"
            class="inline-flex items-center gap-x-1.5 rounded-md bg-green-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-green-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green-600"
          >
            <.icon name="hero-plus-circle" class="-ml-0.5 h-5 w-5" /> <%= gettext("add phone number") %>
          </span>
        </label>

        <div class="grid grid-cols-1 gap-2 sm:grid-cols-6 mt-4">
          <.inputs_for :let={f_pn} field={@form[:emails]}>
            <div class="sm:col-span-2">
              <.input type="hidden" name="contact[emails_sort][]" value={f_pn.index} />
              <.input field={f_pn[:label]} type="select" options={Archie.Contacts.Email.types()} />
            </div>
            <div class="sm:col-span-3">
              <.input field={f_pn[:value]} type="text" />
            </div>
            <label class="sm:col-span-1">
              <input type="checkbox" name="contact[emails_drop][]" value={f_pn.index} class="hidden" />
              <.icon
                name="hero-minus-circle"
                class="w-5 h-5 text-amber-600 hover:text-amber-500 mt-5 relative cursor-pointer"
              />
            </label>
          </.inputs_for>
        </div>

        <input type="hidden" name="contact[emails_drop][]" class="hidden" />

        <label class="block cursor-pointer my-2 mb-4">
          <input type="checkbox" name="contact[emails_sort][]" class="hidden" />
          <span
            type="button"
            class="inline-flex items-center gap-x-1.5 rounded-md bg-green-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-green-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green-600"
          >
            <.icon name="hero-plus-circle" class="-ml-0.5 h-5 w-5" /> <%= gettext("add email") %>
          </span>
        </label>

        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save Contact") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{contact: contact} = assigns, socket) do
    changeset = Contacts.change_contact(contact)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset =
      socket.assigns.contact
      |> Contacts.change_contact(contact_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    save_contact(socket, socket.assigns.action, contact_params)
  end

  defp save_contact(socket, :edit, contact_params) do
    case Contacts.update_contact(socket.assigns.contact, contact_params) do
      {:ok, contact} ->
        notify_parent({:saved, contact})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Contact updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_contact(socket, :new, contact_params) do
    case Contacts.create_contact(contact_params) do
      {:ok, contact} ->
        notify_parent({:saved, contact})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Contact created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
