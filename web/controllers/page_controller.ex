defmodule ChatSample.PageController do
  use ChatSample.Web, :controller
  alias ChatSample.Room

  def index(conn, _params) do
    rooms = Repo.all(Room)
    render conn, "index.html", rooms: rooms
  end
end
