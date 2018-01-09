defmodule Project2.TwodImpMain do
  @moduledoc false

  def start_twoDimp(numNodes) do
    start_nodes(numNodes)
  end

  def start_twoDimp_gossip(numNodes) do
    start_nodes_gossip(numNodes)
  end

  defp start_nodes(numNodes) do
    Enum.map(1..numNodes, fn(x) -> GenServer.start_link(Project2.Node, x) end)
    |> group_neighbors([], 0)
  end

  defp start_nodes_gossip(numNodes) do
    Enum.map(1..numNodes, fn _ -> GenServer.start_link(Project2.GossipNode, 1) end)
    |> group_neighbors([], 0)
  end

  defp group_neighbors([], all, indice) do
    starter = Enum.random(all)
    num = length(all)
    send starter, {:start, self()}
    running(0, num)
  end

  defp group_neighbors(nodes, all, indice) when is_list(nodes) do
    newall =
      if length(all) == 0 do
        getAll(nodes, [])
      else
        all
      end

    [ {:ok, pid} | tail ] = nodes
    n = round(:math.sqrt(length(newall)))
    neighbors =
      cond do
        indice < n ->
          cond do
            indice == 0 ->
              [Enum.at(newall, 1)|[Enum.at(newall, n)|[]]]
            indice == n-1 ->
              [Enum.at(newall, n-2)|[Enum.at(newall, 2*n-1)|[]]]
            :true ->
              [Enum.at(newall, indice-1)|[Enum.at(newall, indice+1)|[Enum.at(newall, indice+n)|[]]]]
          end
        indice >= n*(n-1) ->
          cond do
            indice == n*(n-1) ->
              [Enum.at(newall, n*n-n+1)|[Enum.at(newall, n*n-2*n)|[]]]
            indice == n*n-1 ->
              [Enum.at(newall, n*n-2)|[Enum.at(newall, n*n-n-1)|[]]]
            :true ->
              [Enum.at(newall, indice-1)|[Enum.at(newall, indice+1)|[Enum.at(newall, indice-n)|[]]]]
          end
        indice >= n and :math.fmod(indice, n) == 0 and indice < n*(n-1) ->
          [Enum.at(newall, indice-n)|[Enum.at(newall, indice+1)|[Enum.at(newall, indice+n)|[]]]]
        indice >= n and :math.fmod(indice, n) == n-1 and indice < n*(n-1) ->
          [Enum.at(newall, indice-n)|[Enum.at(newall, indice-1)|[Enum.at(newall, indice+n)|[]]]]
        :true ->
          [Enum.at(newall, indice-1)|[Enum.at(newall, indice+1)|[Enum.at(newall, indice-n)|[Enum.at(newall, indice+n)|[]]]]]
      end
    others = deleteNeighbors(neighbors, newall)
    imp = Enum.random(others)
    neighbors = [imp|neighbors]
    GenServer.cast(pid, [self(), neighbors])
    group_neighbors(tail, newall, indice+1)
  end

  defp deleteNeighbors([], all) do
    all
  end
  defp deleteNeighbors(neighbors, all) do
    [tmp | tail] = neighbors
    all = List.delete(all, tmp)
    deleteNeighbors(tail, all)
  end

  defp getAll([], all) do
    all
  end
  defp getAll(pair, all) do
    [{:ok, pid} | tail ] = pair
    all = all ++ [pid]
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
