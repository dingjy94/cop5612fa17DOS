defmodule Project2.FullMain do
  @moduledoc false

  def start_full(numNodes) do
    start_nodes(numNodes)
  end

  def start_full_gossip(numNodes) do
    start_nodes_gossip(numNodes)
  end

  defp start_nodes(numNodes) do
    Enum.map(1..numNodes, fn(x) -> GenServer.start_link(Project2.Node, x) end)
    |> group_neighbors([])
  end

  defp start_nodes_gossip(numNodes) do
    Enum.map(1..numNodes, fn _ -> GenServer.start_link(Project2.GossipNode, 1) end)
    |> group_neighbors([])
  end

  defp group_neighbors([], all) do
    starter = Enum.random(all)
    num = length(all)
    send starter, {:start, self()}
    running(0, num)
  end

  defp group_neighbors(nodes, all) when is_list(nodes) do
    newall =
      if length(all) == 0 do
        getAll(nodes, [])
      else
        all
      end

    [ {:ok, pid} | tail ] = nodes
    others = List.delete(newall, pid)
    GenServer.cast(pid, [self(), others])
    group_neighbors(tail, newall)
  end

  defp getAll([], all) do
    all
  end
  defp getAll(pair, all) do
    [{:ok, pid} | tail ] = pair
    all =  all ++ [pid]
    getAll(tail, all)
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
