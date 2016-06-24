defmodule ChatSample.RoomController do
  use ChatSample.Web, :controller

  alias ChatSample.Room

  plug :scrub_params, "room" when action in [:create, :update]

  def create(conn, %{"room" => room_params}) do
    changeset = Room.changeset(%Room{}, room_params)

    case Repo.insert(changeset) do
      {:ok, _room} ->
        conn
        |> put_flash(:info, "Room created successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    room = Repo.get!(Room, id)
    logs = Repo.preload(room, :logs).logs
    render(conn, "show.html", room: room, logs: logs)
  end
end
