defmodule PhoenixBookshelf.Repo.Migrations.CreateBook do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :isbn, :string

      timestamps
    end

  end
end
