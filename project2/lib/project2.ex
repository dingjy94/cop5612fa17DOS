defmodule Project2 do
  @moduledoc """
  start point for Project2.
  """


  def main(args) do
    numNodes = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)
    algorithm = Enum.at(args, 2)
    cond do
      algorithm == "push-sum" ->
        cond do
          topology == "line" ->
            Project2.LinkMain.start_link(numNodes)
          topology == "full" ->
            Project2.FullMain.start_full(numNodes)
          topology == "2D" ->
            Project2.TwodMain.start_twoD(numNodes)
          topology == "imp2D" ->
            Project2.TwodImpMain.start_twoDimp(numNodes)
          :true -> IO.puts("topology must be line, full, 2D, imp2D")
        end
      algorithm == "gossip" ->
        cond do
          topology == "line" ->
            Project2.LinkMain.start_line_gossip(numNodes)
          topology == "full" ->
            Project2.FullMain.start_full_gossip(numNodes)
          topology == "2D" ->
            Project2.TwodMain.start_twoD_gossip(numNodes)
          topology == "imp2D" ->
            Project2.TwodImpMain.start_twoDimp_gossip(numNodes)
          :true -> IO.puts("topology must be line, full, 2D, imp2D")
        end
      :true -> IO.puts("algorithm must be push-sum or gossip")

    end
  end

end
