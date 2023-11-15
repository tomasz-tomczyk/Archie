defmodule ArchieWeb.NoteLive.FormComponent do
  use ArchieWeb, :live_component

  alias Archie.Contacts.Contact
  alias Archie.Timeline

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="note-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          :if={!@embedded}
          field={@form[:contact_id]}
          type="select"
          label="Contact"
          options={@contacts}
          prompt="Choose contact..."
        />
        <.input :if={@embedded} field={@form[:contact_id]} type="hidden" />
        <.input field={@form[:body]} type="textarea" label="Note" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Note</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{note: note} = assigns, socket) do
    changeset = Timeline.change_note(note)

    contacts =
      Archie.Contacts.list_contacts()
      |> Enum.map(fn contact ->
        {Contact.display_name(contact), contact.id}
      end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:embedded, fn -> false end)
     |> assign(:contacts, contacts)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"note" => note_params}, socket) do
    changeset =
      socket.assigns.note
      |> Timeline.change_note(note_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"note" => note_params}, socket) do
    save_note(socket, socket.assigns.action, note_params)
  end

  defp save_note(socket, :edit, note_params) do
    case Timeline.update_note(socket.assigns.note, note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_flash(:info, "Note updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_note(socket, :new, note_params) do
    case Timeline.create_note(note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_flash(:info, "Note created successfully")
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
