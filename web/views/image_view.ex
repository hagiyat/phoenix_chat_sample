defmodule ChatSample.ImageView do
  use ChatSample.Web, :view

  def render("show.json", %{image: image}) do
    %{data: render_one(image, ChatSample.ImageView, "image.json")}
  end

  def render("image.json", %{image: image}) do
    %{id: image.id,
      content_type: image.content_type,
      filename: image.filename,
      path: image.path}
  end
end
