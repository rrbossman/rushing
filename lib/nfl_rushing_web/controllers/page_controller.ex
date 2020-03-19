defmodule NflRushingWeb.PageController do
  use NflRushingWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _) do
    live_render(conn, NflRushingWeb.RushersLive)
  end

  def export(conn, params) do
    rushers =
      NflRushingWeb.Rusher.sorted_by_rushers(
        params["sort_by"],
        String.to_atom(params["direction"])
      )

    csv =
      NflRushingWeb.Rusher.filter(rushers, params["filter_text"])
      |> Enum.map(fn r ->
        [
          r.player,
          r.team,
          r.pos,
          r.att,
          r.att_game,
          r.yds,
          r.avg,
          r.yds_game,
          r.td,
          r.lng,
          r.first,
          r.first_percent,
          r.twenty_plus,
          r.forty_plus,
          r.fum
        ]
      end)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"rushers.csv\"")
    |> send_resp(200, csv)
  end
end
