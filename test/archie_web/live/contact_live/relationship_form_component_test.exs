defmodule ArchieWeb.ContactLive.RelationshipFormComponentTest do
  use ArchieWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Archie.ContactsFixtures
  import Archie.RelationshipsFixtures

  defp create_contact(_ctx) do
    contact = contact_fixture()
    %{contact: contact}
  end

  setup [:create_contact]

  test "focusing the input returns available contacts", %{conn: conn, contact: contact} do
    result1 = contact_fixture()
    result2 = contact_fixture()
    result3 = contact_fixture()
    {:ok, show_live, _html} = live(conn, ~p"/contacts/#{contact}")

    html =
      show_live
      |> element("#relationship-contact-search")
      |> render_focus()

    assert html =~ html_escaped(result1.last_name)
    assert html =~ html_escaped(result2.first_name)
    assert html =~ html_escaped(result3.last_name)
  end

  test "searching name returns the relevant contacts", %{conn: conn, contact: contact} do
    result1 =
      contact_fixture(first_name: "FakerWontCreateThis", last_name: "FakerWontCreateThisLastName")

    result2 = contact_fixture()
    result3 = contact_fixture()
    {:ok, show_live, _html} = live(conn, ~p"/contacts/#{contact}")

    html =
      show_live
      |> element("#relationship-contact-search")
      |> render_change(term: "FakerWontCreateThis")

    assert html =~ html_escaped(result1.last_name)
    refute html =~ html_escaped(result2.first_name)
    refute html =~ html_escaped(result3.last_name)
  end

  test "searching a blank phrase returns all available contacts", %{conn: conn, contact: contact} do
    result1 = contact_fixture()
    result2 = contact_fixture()
    {:ok, show_live, _html} = live(conn, ~p"/contacts/#{contact}")

    html =
      show_live
      |> element("#relationship-contact-search")
      |> render_change(term: "")

    assert html =~ html_escaped(result1.first_name)
    assert html =~ html_escaped(result2.last_name)
  end

  test "searching a blank phrase does not include an existing relationship in the results", %{
    conn: conn,
    contact: contact
  } do
    {:ok, show_live, _html} = live(conn, ~p"/contacts/#{contact}")

    # Add the contact after HTML is rendered so we can test that it is not included in the results
    friend = contact_fixture()
    relationship_fixture(source_contact: contact, related_contact: friend)

    html =
      show_live
      |> element("#relationship-contact-search")
      |> render_change(term: "")

    refute html =~ html_escaped(friend.first_name)
  end
end
