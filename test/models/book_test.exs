defmodule PhoenixBookshelf.BookTest do
  use PhoenixBookshelf.ModelCase

  alias PhoenixBookshelf.Book

  @valid_attrs %{isbn: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Book.changeset(%Book{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Book.changeset(%Book{}, @invalid_attrs)
    refute changeset.valid?
  end
end
