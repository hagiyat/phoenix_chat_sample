defmodule ChatSample.ImageController do
  use ChatSample.Web, :controller

  alias ChatSample.Image

  def create(conn, %{"file" => %Plug.Upload{content_type: content_type, filename: filename, path: path}}) do
    zatsu = File.stat!(path, time: :posix) |> Map.fetch!(:mtime)
    :ok = File.rename(path, "logs/#{zatsu}")

    changeset = %Image{content_type: content_type, filename: filename, path: "logs/#{zatsu}"}
    case Repo.insert(changeset) do
      {:ok, image} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", image_path(conn, :show, image))
        |> render("show.json", image: image)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChatSample.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Repo.get!(Image, id)
    conn
    |> put_resp_content_type(image.content_type)
    |> put_resp_header("content-disposition", "attachment; filename=#{image.filename}")
    |> send_file(200, image.path)
  end
end
