defmodule NflRushingWeb.RushersLive do
  use NflRushingWeb, :controller
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(NflRushingWeb.RushersView, "index.html", assigns)
  end

  def mount(_, socket) do
    {ok, rushers} = NflRushingWeb.Rusher.rushers()
    {:ok, assign(socket, rushers: rushers)}
  end
end
