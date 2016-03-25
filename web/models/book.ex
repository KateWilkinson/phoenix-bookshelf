defmodule PhoenixBookshelf.Book do
  use PhoenixBookshelf.Web, :model

  schema "books" do
    field :title, :string
    field :isbn, :string

    timestamps
  end

  @required_fields ~w(title isbn)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
