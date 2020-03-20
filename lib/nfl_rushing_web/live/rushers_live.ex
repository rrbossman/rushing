defmodule NflRushingWeb.RushersLive do
  use Phoenix.LiveView

  @page_size 20
  @page_number 1
  @page_delta 2

  def render(assigns) do
    Phoenix.View.render(NflRushingWeb.RushersView, "index.html", assigns)
  end

  def mount(_, _, socket) do
    {_, rushers} = NflRushingWeb.Rusher.rushers()

    {paged_rushers, pagination_list} =
      paginate(
        rushers,
        "",
        %{page: @page_number, page_size: @page_size}
      )

    {:ok,
     assign(socket,
       sorted_rushers: rushers,
       rushers: paged_rushers,
       pagination_list: pagination_list,
       sort_by: "player",
       direction: :asc,
       filter_text: "",
       current_page: 1,
       pagination_config: %{page: @page_number, page_size: @page_size}
     )}
  end

  def paginate(rushers, filter_text, pagination_config) do
    pagination =
      Scrivener.paginate(
        NflRushingWeb.Rusher.filter(rushers, filter_text),
        pagination_config
      )

    {pagination,
     create_pagination_list(
       [],
       pagination.page_number,
       round(pagination.total_pages / 2),
       pagination.total_pages,
       pagination.total_pages
     )}
  end

  def create_pagination_list(list, _, _, _, n) when n < 1 do
    list
  end

  def create_pagination_list(list, cp, m, tp, n) do
    cond do
      n <= 3 || (n <= 5 && cp <= 3) || n == tp || (n >= cp - @page_delta && n <= cp + @page_delta) ||
          (n >= m - @page_delta && n <= m + @page_delta) ->
        create_pagination_list([n | list], cp, m, tp, n - 1)

      List.first(list) != "..." ->
        create_pagination_list(["..." | list], cp, m, tp, n - 1)

      true ->
        create_pagination_list(list, cp, m, tp, n - 1)
    end
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

    {paged_rushers, pagination_list} =
      paginate(
        rushers,
        socket.assigns.filter_text,
        socket.assigns.pagination_config
      )

    {:noreply,
     assign(socket,
       sorted_rushers: rushers,
       rushers: paged_rushers,
       pagination_list: pagination_list,
       sort_by: sort_by,
       direction: direction
     )}
  end

  def handle_event("filter", %{"name" => val}, socket) do
    {paged_rushers, pagination_list} =
      paginate(
        socket.assigns.sorted_rushers,
        val,
        socket.assigns.pagination_config
      )

    {:noreply,
     assign(socket,
       rushers: paged_rushers,
       pagination_list: pagination_list,
       filter_text: val
     )}
  end

  def handle_event("paginate", %{"page" => val}, socket) do
    {page, _} = Integer.parse(val)

    {paged_rushers, pagination_list} =
      paginate(
        NflRushingWeb.Rusher.filter(socket.assigns.sorted_rushers, socket.assigns.filter_text),
        socket.assigns.filter_text,
        %{page: page, page_size: @page_size}
      )

    {:noreply,
     assign(socket,
       rushers: paged_rushers,
       pagination_list: pagination_list,
       pagination_config: %{page: page, page_size: @page_size},
       current_page: page
     )}
  end
end
