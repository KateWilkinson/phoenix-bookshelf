defmodule PhoenixBookshelf.Repo.Migrations.AddFieldsToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :image_url, :string
    end
  end
end
