defmodule DragWeb.PageController do
  use DragWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
