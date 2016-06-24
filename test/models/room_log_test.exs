defmodule ChatSample.RoomLogTest do
  use ChatSample.ModelCase

  alias ChatSample.RoomLog

  @valid_attrs %{message: "some content", user_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RoomLog.changeset(%RoomLog{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RoomLog.changeset(%RoomLog{}, @invalid_attrs)
    refute changeset.valid?
  end
end
