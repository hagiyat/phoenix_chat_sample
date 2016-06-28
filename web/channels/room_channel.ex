defmodule ChatSample.RoomChannel do
  use ChatSample.Web, :channel
  require Logger

  alias ChatSample.Room
  alias ChatSample.Image

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
    channel = if ChatSample.RoomView.image?(msg["body"]), do: "new:img", else: "new:msg"
    broadcast! socket, channel, %{user: msg["user"], body: msg["body"]}

    "rooms:" <> room_id = socket.topic
    {:ok, _pid} =
      Task.start(fn ->
        log = Ecto.build_assoc(Repo.get(Room, room_id), :logs)
        Repo.insert(%{log | user_name: msg["user"], message: msg["body"]})
      end)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def handle_in("new:resource", msg, socket) do
    "rooms:" <> room_id = socket.topic
    {:ok, _pid} =
      Task.start(fn ->
        path = "logs/#{DateTime.to_unix(DateTime.utc_now)}"
        {:ok, :ok} = File.open(path, [:write], fn(file) -> IO.write(file, msg["raw_data"]) end)

        Repo.transaction fn ->
          image = %Image{content_type: msg["content_type"], filename: msg["filename"], path: path}
          saved_image = Repo.insert!(image)
          log = Ecto.build_assoc(Repo.get(Room, room_id), :logs)
          local_path = ChatSample.Router.Helpers.image_path(ChatSample.Endpoint, :show, saved_image.id)
          Repo.insert(%{log | user_name: msg["user"], message: local_path})

          broadcast! socket, "new:img", %{user: msg["user"], body: local_path}
        end

      end)
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end
end
