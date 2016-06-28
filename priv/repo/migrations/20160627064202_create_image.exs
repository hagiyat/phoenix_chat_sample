defmodule ChatSample.Repo.Migrations.CreateImage do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :content_type, :string
      add :filename, :string
      add :path, :string

      timestamps()
    end

  end
end
