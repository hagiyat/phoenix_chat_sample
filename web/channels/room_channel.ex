defmodule ChatSample.RoomChannel do
  use ChatSample.Web, :channel
  require Logger

  alias ChatSample.Room

  def join("rooms:lobby", message, socket) do
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, message, "lobby"})

    {:ok, socket}
  end

  def join("rooms:" <> room_id, message, socket) do
    case Repo.get(Room, room_id) do
      %Room{} ->
        Process.flag(:trap_exit, true)
        :timer.send_interval(5000, :ping)
        send(self, {:after_join, message, room_id})
        {:ok, socket}
      _ ->
        {:error, %{reason: "invalid room"}}
    end
  end

  # def join("rooms:" <> _private_subtopic, _message, _socket) do
  #   {:error, %{reason: "unauthorized"}}
  # end

  def handle_info({:after_join, msg, _room_id}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "system:ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug "> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    "rooms:" <> room_id = socket.topic
    {:ok, _pid} =
      Task.start(fn ->
        log = Ecto.build_assoc(Repo.get(Room, room_id), :logs)
        Repo.insert(%{log | user_name: msg["user"], message: msg["body"]})
      end)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end
end
