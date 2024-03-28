defmodule ArchieWeb.NoteLiveTest do
  use ArchieWeb.ConnCase, async: false

  import Archie.ContactsFixtures
  import Archie.TimelineFixtures
  import Phoenix.LiveViewTest

  @invalid_attrs %{body: nil}

  defp create_note(_ctx) do
    note = note_fixture()
    %{note: note}
  end

  describe "Index" do
    setup [:create_note]

    test "lists all notes", %{conn: conn, note: note} do
      {:ok, _index_live, html} = live(conn, ~p"/notes")

      assert html =~ "Listing Notes"
      assert html =~ note.body
    end

    test "saves new note", %{conn: conn} do
      contact = contact_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/notes")

      assert index_live |> element("a", "New Note") |> render_click() =~
               "New Note"

      assert_patch(index_live, ~p"/notes/new")

      assert index_live
             |> form("#note-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#note-form", note: %{contact_id: contact.id, body: "some body"})
             |> render_submit()

      assert_patch(index_live, ~p"/notes")

      html = render(index_live)
      assert html =~ "Note created successfully"
      assert html =~ "some body"
    end
  end
end
