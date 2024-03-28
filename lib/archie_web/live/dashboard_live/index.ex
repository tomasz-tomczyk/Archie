defmodule ArchieWeb.DashboardLive.Index do
  @moduledoc false
  use ArchieWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>Hello world</div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:path, "home")
     |> assign(:page_title, gettext("Edit Contact"))}
  end
end
