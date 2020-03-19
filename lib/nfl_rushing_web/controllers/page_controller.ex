defmodule NflRushingWeb.PageController do
  use NflRushingWeb, :controller

  def get_json(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Poison.decode(body), do: {:ok, json}
  end

  def index(conn, _params) do
    {ok, json} = get_json("data/rushing.json")

    rushers =
      Enum.map(json, fn rusher ->
        %NflRushingWeb.Rusher{
          player: rusher["Player"],
          team: rusher["Team"],
          pos: rusher["Pos"],
          att: rusher["Att"],
          att_game: rusher["Att/G"],
          yds: rusher["Yds"],
          avg: rusher["Avg"],
          yds_game: rusher["Yds/G"],
          td: rusher["TD"],
          lng: rusher["Lng"],
          first: rusher["1st"],
          first_percent: rusher["1st%"],
          twenty_plus: rusher["20+"],
          forty_plus: rusher["40+"],
          fum: rusher["FUM"]
        }
      end)

    IO.inspect(rushers)

    render(conn, "index.html", rushers: rushers)
  end
end
