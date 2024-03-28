defmodule ArchieWeb.ContactLive.ShowTest do
  use ArchieWeb.ConnCase, async: false

  import Archie.ContactsFixtures
  import Phoenix.LiveViewTest

  @update_attrs %{
    dob: "2023-10-08",
    first_name: "some updated first_name",
    last_name: "some updated last_name"
  }
  @invalid_attrs %{dob: nil, first_name: nil, last_name: nil}

  defp create_contact(_ctx) do
    contact = contact_fixture(first_name: "John")
    %{contact: contact}
  end

  setup [:create_contact]

  test "displays contact", %{conn: conn, contact: contact} do
    {:ok, _show_live, html} = live(conn, ~p"/contacts/#{contact}")

    assert html =~ contact.first_name
    assert html =~ contact.last_name
  end

  test "updates contact within modal", %{conn: conn, contact: contact} do
    {:ok, show_live, _html} = live(conn, ~p"/contacts/#{contact}")

    assert show_live |> element("a", "Edit") |> render_click() =~
             "John"

    assert_patch(show_live, ~p"/contacts/#{contact}/show/edit")

    assert show_live
           |> form("#contact-form", contact: @invalid_attrs)
           |> render_change() =~ "can&#39;t be blank"

    assert show_live
           |> form("#contact-form", contact: @update_attrs)
           |> render_submit()

    assert_patch(show_live, ~p"/contacts/#{contact}")

    html = render(show_live)
    assert html =~ "Contact updated successfully"
    assert html =~ "some updated first_name"
  end
end
