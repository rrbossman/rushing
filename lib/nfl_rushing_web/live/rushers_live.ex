defmodule NflRushingWeb.RushersLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(NflRushingWeb.RushersView, "index.html", assigns)
  end

  def mount(_, socket) do
    {_, rushers} = NflRushingWeb.Rusher.rushers()

    {:ok,
     assign(socket,
       sorted_rushers: rushers,
       rushers: rushers,
       sort_by: "player",
       direction: :asc,
       filter_text: ""
     )}
  end

  def handle_event("sort", %{"sort-by" => sort_by}, socket) do
    {rushers, direction} =
      case {socket.assigns.sort_by, socket.assigns.direction} do
        {^sort_by, :asc} ->
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, :desc), :desc}

        {^sort_by, :desc} ->
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, :asc), :asc}

        {_, _} ->
          initial_direction = NflRushingWeb.Rusher.initial_direction(sort_by)
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, initial_direction), initial_direction}
      end

    {:noreply,
     assign(socket,
       sorted_rushers: rushers,
       rushers: NflRushingWeb.Rusher.filter(rushers, socket.assigns.filter_text),
       sort_by: sort_by,
       direction: direction
     )}
  end

  def handle_event("filter", %{"name" => val}, socket) do
    {:noreply,
     assign(socket,
       rushers: NflRushingWeb.Rusher.filter(socket.assigns.sorted_rushers, val),
       filter_text: val
     )}
  end
end
