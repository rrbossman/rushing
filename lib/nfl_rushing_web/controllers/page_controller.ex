defmodule NflRushingWeb.PageController do
  use NflRushingWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _) do
    live_render(conn, NflRushingWeb.RushersLive)
  end
end
