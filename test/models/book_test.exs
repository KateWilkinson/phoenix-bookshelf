defmodule PhoenixBookshelf.BookTest do
  use PhoenixBookshelf.ModelCase

  alias PhoenixBookshelf.Book

  @valid_attrs %{isbn: "9781408855713",
                 title: "Harry Potter and the Deathly Hallows",
                 image_url: "http://harrypotterfanzone.com/wp-content/2009/06/dh_signature.jpg"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Book.changeset(%Book{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Book.changeset(%Book{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "title is not a required field" do
    changeset = Book.changeset(%Book{}, Map.delete(@valid_attrs, :title))
    assert changeset.valid?
  end

  test "image url is not a required field" do
    changeset = Book.changeset(%Book{}, Map.delete(@valid_attrs, :image_url))
    assert changeset.valid?
  end

  test "ISBN must be at least 10 characters long" do
    attrs = %{@valid_attrs | isbn: "123"}
    assert {:isbn, {"should be at least %{count} character(s)", [count: 10]}} in errors_on(%Book{}, attrs)
  end

  test "ISBN must not be longer than 13 characters" do
    attrs = %{@valid_attrs | isbn: "123456789101112"}
    assert {:isbn, {"should be at most %{count} character(s)", [count: 13]}} in errors_on(%Book{}, attrs)
  end

  test "ISBN must not contain letters" do
    attrs = %{@valid_attrs | isbn: "abcdefghik"}
    assert {:isbn, "has invalid format"} in errors_on(%Book{}, attrs)
  end

  test "ISBN must not contain special characters" do
    attrs = %{@valid_attrs | isbn: "123456789@"}
    changeset = Book.changeset(%Book{}, attrs)
    assert {:isbn, "has invalid format"} in errors_on(%Book{}, attrs)
  end

  test "ISBN must be unique" do
    %Book{}
    |> Book.changeset(@valid_attrs)
    |> PhoenixBookshelf.Repo.insert!
    book2 =
      %Book{}
      |> Book.changeset(@valid_attrs)
    assert {:error, changeset} = Repo.insert(book2)
    assert changeset.errors[:isbn] == "ISBN has already been added"
  end
end
