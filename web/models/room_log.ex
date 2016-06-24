defmodule ChatSample.RoomLog do
  use ChatSample.Web, :model

  schema "room_logs" do
    field :user_name, :string
    field :message, :string
    belongs_to :room, ChatSample.Room

    timestamps
  end

  @required_fields ~w(message)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
