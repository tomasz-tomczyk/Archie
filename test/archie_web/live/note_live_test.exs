defmodule ArchieWeb.NoteLiveTest do
  use ArchieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Archie.TimelineFixtures
  import Archie.ContactsFixtures

  @update_attrs %{body: "some updated body"}
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

    test "updates note in listing", %{conn: conn, note: note} do
      {:ok, index_live, _html} = live(conn, ~p"/notes")

      assert index_live |> element("#notes-#{note.id} a", "Edit") |> render_click() =~
               "Edit Note"

      assert_patch(index_live, ~p"/notes/#{note}/edit")

      assert index_live
             |> form("#note-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#note-form", note: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/notes")

      html = render(index_live)
      assert html =~ "Note updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes note in listing", %{conn: conn, note: note} do
      {:ok, index_live, _html} = live(conn, ~p"/notes")

      assert index_live |> element("#notes-#{note.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#notes-#{note.id}")
    end
  end
end
