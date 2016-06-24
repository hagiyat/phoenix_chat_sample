defmodule ChatSample.Repo.Migrations.CreateRoomLog do
  use Ecto.Migration

  def change do
    create table(:room_logs) do
      add :user_name, :string
      add :message, :string
      add :room_id, references(:rooms, on_delete: :nothing)

      timestamps
    end
    create index(:room_logs, [:room_id])

  end
end
