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
       paged_rushers: paged_rushers,
       pagination_list: pagination_list,
       sort_by: "player",
       direction: :asc,
       filter_text: "",
       current_page: 1,
       timer_ref: nil,
       loading: false
     )}
  end

  def handle_event("sort", %{"sort-by" => sort_by}, %{assigns: %{loading: false}} = socket) do
    timer_ref = Process.send_after(self(), :sort, 0)
    {:noreply, assign(socket, sort_by: sort_by, timer_ref: timer_ref, loading: true)}
  end

  def handle_info(
        :sort,
        %{
          assigns: %{
            :direction => direction,
            :sort_by => sort_by,
            :current_page => current_page,
            :filter_text => filter_text
          }
        } = socket
      ) do
    {rushers, new_direction} =
      case direction do
        :asc ->
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, :desc), :desc}

        :desc ->
          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, :asc), :asc}

        _ ->
          initial_direction = NflRushingWeb.Rusher.initial_direction(sort_by)

          {NflRushingWeb.Rusher.sorted_by_rushers(sort_by, initial_direction), initial_direction}
      end

    {paged_rushers, pagination_list} =
      paginate(
        rushers,
        filter_text,
        %{page: current_page, page_size: @page_size}
      )

    {:noreply,
     assign(socket,
       sorted_rushers: rushers,
       paged_rushers: paged_rushers,
       pagination_list: pagination_list,
       direction: new_direction,
       loading: false,
       timer_ref: nil
     )}
  end

  def handle_event("filter", %{"name" => val}, %{assigns: %{loading: true}} = socket) do
    {:noreply, assign(socket, filter_text: val)}
  end

  def handle_event("filter", %{"name" => val}, %{assigns: %{loading: false}} = socket) do
    timer_ref = Process.send_after(self(), :filter, 700)
    {:noreply, assign(socket, filter_text: val, timer_ref: timer_ref, loading: true)}
  end

  def handle_info(
        :filter,
        %{assigns: %{:sorted_rushers => sorted_rushers, :filter_text => filter_text}} = socket
      ) do
    {paged_rushers, pagination_list} =
      paginate(
        sorted_rushers,
        filter_text,
        %{page: 1, page_size: @page_size}
      )

    {:noreply,
     assign(socket,
       paged_rushers: paged_rushers,
       pagination_list: pagination_list,
       current_page: 1,
       loading: false,
       timer_ref: nil
     )}
  end

  def handle_event("paginate", %{"page" => page}, %{assigns: %{loading: false}} = socket) do
    timer_ref = Process.send_after(self(), :paginate, 0)
    {current_page, _} = Integer.parse(page)
    {:noreply, assign(socket, current_page: current_page, timer_ref: timer_ref, loading: true)}
  end

  def handle_info(
        :paginate,
        %{
          assigns: %{
            :sorted_rushers => sorted_rushers,
            :filter_text => filter_text,
            :current_page => current_page
          }
        } = socket
      ) do
    {paged_rushers, pagination_list} =
      paginate(
        NflRushingWeb.Rusher.filter(sorted_rushers, filter_text),
        filter_text,
        %{page: current_page, page_size: @page_size}
      )

    {:noreply,
     assign(socket,
       paged_rushers: paged_rushers,
       pagination_list: pagination_list,
       loading: false,
       timer_ref: nil
     )}
  end

  defp paginate(rushers, filter_text, pagination_config) do
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

  defp create_pagination_list(list, _, _, tp, n) when n < 1 or tp == 1 do
    list
  end

  defp create_pagination_list(list, cp, m, tp, n) do
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
end
