defmodule ChatSample.RoomView do
  use ChatSample.Web, :view

  def image?(message) do
    String.contains?(message, ChatSample.Router.Helpers.image_path(ChatSample.Endpoint, :create))
    ||
    ~r/(https?)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)\.(jpg|gif|png)/
    |> Regex.match?(message)
  end
end
