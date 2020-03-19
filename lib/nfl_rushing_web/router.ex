defmodule NflRushingWeb.Router do
  use NflRushingWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", NflRushingWeb do
    pipe_through :browser

    live "/", RushersLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", NflRushingWeb do
  #   pipe_through :api
  # end
end
