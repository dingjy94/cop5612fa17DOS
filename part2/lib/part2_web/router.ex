defmodule Part2Web.Router do
  use Part2Web, :router

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

  scope "/", Part2Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", LoginController, :login
    get "/tweet", TweetController, :tweet
    get "/query", QueryController, :query
    get "/subscribe", SubscribeController, :sub
  end

  # Other scopes may use custom stacks.
  # scope "/api", Part2Web do
  #   pipe_through :api
  # end
end
