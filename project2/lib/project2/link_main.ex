defmodule Project2.LinkMain do
  @moduledoc """
  main process for link topology
"""


  def start_link(numNodes) do
    start_nodes(numNodes)
  end

  def start_line_gossip(numNodes) do
    start_nodes_gossip(numNodes)
  end

  defp start_nodes(numNodes) do
    Enum.map(1..numNodes, fn(x) -> GenServer.start_link(Project2.Node, x) end)
    |> group_neighbors(0, [])
  end

  defp start_nodes_gossip(numNodes) do
    Enum.map(1..numNodes, fn _ -> GenServer.start_link(Project2.GossipNode, 1) end)
    |> group_neighbors(0, [])
  end

  defp group_neighbors([], pre, all) do
    {:ok, starter} = Enum.random(all)
    num = length(all)
    send starter, {:start, self()}
    running(0, num)
  end

  defp group_neighbors(nodes, pre, all) when is_list(nodes) do
    newall =
      if length(all) == 0 do
        nodes
      else
        all
      end
    [ {:ok, pid} | tail ] = nodes
    if pre == 0 do
      [ {:ok, next} | tmp ] = tail
      GenServer.cast(pid, [self(), [next]])
    else
      if length(tail) == 0 do
        GenServer.cast(pid, [self(), [pre]])
      else
        [ {:ok, next} | tmp ] = tail
        GenServer.cast(pid, [self(), [pre, next]])
      end
    end
    group_neighbors(tail, pid, newall)
  end

  defp running(completed, num) when completed == num do
    IO.puts :os.system_time(:millisecond)
    IO.puts "all nodes finished"
  end
  defp running(completed, num) when completed != num do
    receive do
      {:started, pid} ->
        IO.puts :os.system_time(:millisecond)
        IO.puts "start commuication between nodes"
        running(0, num)
      {:finish, pid} ->
        running(completed+1, num)
    end
  end
end
