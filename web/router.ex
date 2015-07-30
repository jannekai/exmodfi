defmodule Exmodfi.Router do
  use Exmodfi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  scope "/", Exmodfi do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/:page", PageController, :show
    get "/article/:article", PageController, :show
  end

end
