defmodule PhoenixBookshelf.BookController do
  use PhoenixBookshelf.Web, :controller

  alias PhoenixBookshelf.Book

  plug :scrub_params, "book" when action in [:create, :update]

  def index(conn, _params) do
    books = Repo.all(Book)
    render(conn, "index.html", books: books)
  end

  def new(conn, _params) do
    changeset = Book.changeset(%Book{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"book" => book_params}) do
    changeset = Book.changeset(%Book{}, book_params)

    case Repo.insert(changeset) do
      {:ok, _book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: book_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    isbn = book.isbn
    title = Book.get_attribute("Title", isbn)
    author = Book.get_attribute("Author", isbn)
    publisher = Book.get_attribute("Publisher", isbn)
    render(conn, "show.html", book: book, title: title, author: author, publisher: publisher)
  end

  def edit(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)
    changeset = Book.changeset(book)
    render(conn, "edit.html", book: book, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Repo.get!(Book, id)
    changeset = Book.changeset(book, book_params)

    case Repo.update(changeset) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: book_path(conn, :show, book))
      {:error, changeset} ->
        render(conn, "edit.html", book: book, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Repo.get!(Book, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: book_path(conn, :index))
  end
end
