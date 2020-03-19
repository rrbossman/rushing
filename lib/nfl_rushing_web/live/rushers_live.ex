defmodule NflRushingWeb.RushersLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(NflRushingWeb.RushersView, "index.html", assigns)
  end

  def mount(_, socket) do
    {ok, rushers} = NflRushingWeb.Rusher.rushers()
    {:ok, assign(socket, rushers: rushers)}
  end

  def handle_event("sort", %{"sort-by" => sort_by}, socket) do
    rushers = NflRushingWeb.Rusher.sorted_by_rushers(sort_by)
    {:noreply, assign(socket, rushers: rushers)}
  end
end
