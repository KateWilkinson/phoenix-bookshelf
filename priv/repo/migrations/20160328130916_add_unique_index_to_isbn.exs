defmodule PhoenixBookshelf.Repo.Migrations.AddUniqueIndexToIsbn do
  use Ecto.Migration

  def change do
    create unique_index(:books, [:isbn])
  end
end
