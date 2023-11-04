defmodule ArchieWeb.ContactLiveTest do
  use ArchieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Archie.ContactsFixtures

  @create_attrs %{
    dob: "2023-10-07",
    first_name: "John",
    last_name: "some last_name"
  }
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

  test "lists all contacts", %{conn: conn, contact: contact} do
    {:ok, _index_live, html} = live(conn, ~p"/contacts")

    assert html =~ "List of your contacts"
    assert html =~ contact.first_name
  end

  test "saves new contact", %{conn: conn} do
    {:ok, index_live, _html} = live(conn, ~p"/contacts")

    assert index_live |> element("header a", "New Contact") |> render_click() =~
             "New Contact"

    assert_patch(index_live, ~p"/contacts/new")

    assert index_live
           |> form("#contact-form", contact: @invalid_attrs)
           |> render_change() =~ "can&#39;t be blank"

    assert index_live
           |> form("#contact-form", contact: @create_attrs)
           |> render_submit()

    assert_patch(index_live, ~p"/contacts")

    html = render(index_live)
    assert html =~ "Contact created successfully"
    assert html =~ "John"
  end

  test "updates contact in listing", %{conn: conn, contact: contact} do
    {:ok, index_live, _html} = live(conn, ~p"/contacts")

    assert index_live |> element("#contacts-#{contact.id} a", "Edit") |> render_click() =~
             "Edit Contact"

    assert_patch(index_live, ~p"/contacts/#{contact}/edit")

    assert index_live
           |> form("#contact-form", contact: @invalid_attrs)
           |> render_change() =~ "can&#39;t be blank"

    assert index_live
           |> form("#contact-form", contact: @update_attrs)
           |> render_submit()

    assert_patch(index_live, ~p"/contacts")

    html = render(index_live)
    assert html =~ "Contact updated successfully"
    assert html =~ "some updated first_name"
  end

  test "deletes contact in listing", %{conn: conn, contact: contact} do
    {:ok, index_live, _html} = live(conn, ~p"/contacts")

    assert index_live |> element("#contacts-#{contact.id} a", "Delete") |> render_click()
    refute has_element?(index_live, "#contacts-#{contact.id}")
  end
end
