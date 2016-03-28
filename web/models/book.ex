defmodule PhoenixBookshelf.Book do
  use PhoenixBookshelf.Web, :model

  schema "books" do
    field :title, :string
    field :isbn, :string
    field :image_url, :string

    timestamps
  end

  @required_fields ~w(isbn)
  @optional_fields ~w(title image_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:isbn, min: 10)
    |> validate_length(:isbn, max: 13)
    |> validate_format(:isbn, ~r/^[0-9]*$/)
    |> unique_constraint(:isbn, message: "ISBN has already been added")
  end
end
