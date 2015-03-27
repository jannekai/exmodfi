defmodule Exmodfi.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  scope "/", Exmodfi do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/article/:article", ArticleController, :article
  end

end
