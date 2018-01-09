defmodule Bitcoin.ServerNode do
  @moduledoc """
  master of bitcoin mining
  manage all workers
  output bitcoin key, value pair
"""
  @minVal :minVal
  @workerNmu 5
  @blockRange 100
  @numOfZero :numOfZero
  @result :result
  @count :count

  def start_server(numOfZero, ip) do
    IO.puts "Master server starts"
    Agent.start_link(fn -> 1 end, name: {:global, @minVal})
    Agent.start_link(fn -> 1 end, name: @count)
    Agent.start_link(fn -> numOfZero end, name: {:global, @numOfZero})
    start_workers(numOfZero)
  end

  def start_workers(numOfZero) when is_integer(numOfZero) do
    Enum.map(1..@workerNmu, fn _ -> GenServer.start_link(Bitcoin.WorkerNode, numOfZero) end)
    |> start_mining(numOfZero)
  end

  defp start_mining([], numOfZero) do
    running(numOfZero)
  end

  defp start_mining(workers, numOfZero) when is_list(workers) do
    [ {:ok, pid} | tail ] = workers
    IO.inspect(pid)
    minVal = :global.whereis_name(@minVal)
    cur_val = Agent.get_and_update(minVal, &({ &1, &1 + @blockRange }))
    GenServer.cast(pid, [ cur_val, @blockRange, self() ])
    start_mining(tail, numOfZero)
  end


  defp running(numOfZero) do
    receive do
      {{key, value}, pid} ->
        count = Agent.get_and_update(:count, &({ &1, &1 + 1 }))
        IO.puts to_string(count) <> <<9>> <> to_string(key) <> <<9>> <> value
        running(numOfZero)
      {:finish, pid} ->
        minVal = :global.whereis_name(@minVal)
        cur_val = Agent.get_and_update(minVal, &({ &1, &1 + @blockRange }))
        GenServer.cast(pid, [ cur_val, @blockRange, self() ])
        running(numOfZero)
      {:remoteWorker, pid} ->
        IO.puts "Remote worker #{inspect pid} start"
        send(pid, { numOfZero })
        running(numOfZero)
    end
  end
end
