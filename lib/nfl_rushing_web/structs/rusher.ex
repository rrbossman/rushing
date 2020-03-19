defmodule NflRushingWeb.Rusher do
  use Memoize

  defstruct player: "",
            team: "",
            pos: "",
            att: 0,
            att_game: 0,
            yds: 0,
            avg: 0,
            yds_game: 0,
            td: 0,
            lng: 0,
            first: 0,
            first_percent: 0,
            twenty_plus: 0,
            forty_plus: 0,
            fum: 0

  def get_json(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Poison.decode(body), do: {:ok, json}
  end

  defmemo rushers do
    {ok, json} = get_json("data/rushing.json")

    IO.puts("Loading data...")

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

    {ok, rushers}
  end
end
