defmodule Bitcoin.RemoteNode do
  @moduledoc"""
  manager of remote node
  connect with server node to get minval and send output
"""
  @minVal :minVal
  @workerNmu 5
  @blockRange 100
  @numOfZero :numOfZero


  def start_remoteWorker(ip, serverIp) do
    connect_server(ip, serverIp)
  end

  defp connect_server(ip, serverIp) do
    nodename = String.to_atom("remoteWorker@" <> ip)
    Node.start(nodename)
    Node.set_cookie(Node.self, :"dingjy")
    servername = String.to_atom("server@" <> serverIp)
    case Node.connect(servername) do
      :true ->
        :timer.sleep(1000)
        :global.whereis_name(servername)
        |> init
    end
  end

  defp init(pid) do
    if send(pid, {:remoteWorker, self()}) == :flse do
      IO.puts "Connect to server filed"
    else
      IO.puts "Conncet to server successfully"
      receive do
        { numOfZero } ->
          start_workers(numOfZero, @workerNmu, pid)
      end
    end
  end

  defp start_workers(numOfZero, workerNum, serverPid) when is_integer(numOfZero) do
    Enum.map(1..workerNum, fn _ -> Tuple.append(GenServer.start_link(Bitcoin.WorkerNode, numOfZero), serverPid) end)
    |> start_mining
  end

  defp start_mining([]), do: running()
  defp start_mining(workers) when is_list(workers) do
    [ {:ok, pid, severPid} | tail ] = workers
    minVal = :global.whereis_name(@minVal)
    cur_val = Agent.get_and_update(minVal, &({ &1, &1 + @blockRange }))
    GenServer.cast(pid, [ cur_val, @blockRange, severPid ])
    start_mining(tail)
  end

  defp running() do
    running()
  end


end
