defmodule PhoenixBookshelf.HelloController do
  use PhoenixBookshelf.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
