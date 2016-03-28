defmodule PhoenixBookshelf.Router do
  use PhoenixBookshelf.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixBookshelf do
    pipe_through :browser # Use the default browser stack

    get "/", BookController, :index
    resources "/books", BookController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixBookshelf do
  #   pipe_through :api
  # end
end
