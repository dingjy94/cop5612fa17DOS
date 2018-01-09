defmodule Serverrtn do
    use GenServer

    def start_link(opts \\[0] )do
        GenServer.start_link(__MODULE__, :ok, opts)
    end    

    def init(:ok) do
        {:ok, [0]}
    end

    def handle_cast({:write, numNodes}, state) do
        {:noreply, state ++ [numNodes]}
    end

    def handle_cast({:finish, key}, state) do
        currentnumber = hd(state) + 1
        state = [currentnumber] ++ tl(state)
        IO.inspect currentnumber
        if hd(state) == hd(tl(state)) do
            IO.inspect "end"
        end        
        {:noreply, state}
    end


end