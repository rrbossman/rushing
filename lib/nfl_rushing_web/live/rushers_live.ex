defmodule NflRushingWeb.RushersLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(NflRushingWeb.RushersView, "index.html", assigns)
  end

  def mount(_, socket) do
    {ok, rushers} = NflRushingWeb.Rusher.rushers()
    {:ok, assign(socket, rushers: rushers, sort_by: "player", direction: :asc)}
  end

  def handle_event("sort", %{"sort-by" => sort_by}, socket) do
    {rushers, direction} =
      case {socket.assigns.sort_by, socket.assigns.direction} do
        {^sort_by, :asc} ->
          IO.puts(1)
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, :desc), :desc}

        {^sort_by, :desc} ->
          IO.puts(2)
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, :asc), :asc}

        {_, _} ->
          initial_direction = NflRushingWeb.Rusher.initial_direction(sort_by)
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, initial_direction), initial_direction}

        _ ->
          {socket.assigns.rushers, socket.assigns.direction}
      end

    {:noreply, assign(socket, rushers: rushers, sort_by: sort_by, direction: direction)}
  end
end
