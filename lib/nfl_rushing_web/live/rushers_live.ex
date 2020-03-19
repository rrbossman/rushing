defmodule NflRushingWeb.RushersLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(NflRushingWeb.RushersView, "index.html", assigns)
  end

  def mount(_, socket) do
    {ok, rushers} = NflRushingWeb.Rusher.rushers()

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

        _ ->
          {socket.assigns.rushers, socket.assigns.direction}
      end

    {:noreply,
     assign(socket,
       sorted_rushers: rushers,
       rushers: filter(rushers, socket.assigns.filter_text),
       sort_by: sort_by,
       direction: direction
     )}
  end

  def handle_event("filter", %{"name" => val}, socket) do
    {:noreply, assign(socket, rushers: filter(socket.assigns.rushers, val), filter_text: val)}
  end

  def filter(rushers, val) do
    name = String.downcase(val)

    Enum.filter(rushers, fn r ->
      IO.inspect(String.contains?(String.downcase(r.player), name))
      String.contains?(String.downcase(r.player), name)
    end)
  end
end
