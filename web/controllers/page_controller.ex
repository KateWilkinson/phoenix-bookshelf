defmodule PhoenixBookshelf.PageController do
  use PhoenixBookshelf.Web, :controller

  def index(conn, _params) do
    redirect conn, to: "/books"
  end
end
