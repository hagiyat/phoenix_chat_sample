defmodule ChatSample.PageController do
  use ChatSample.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
