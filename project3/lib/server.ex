defmodule Server do
    use GenServer

    def start_link(opts \\[0] )do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        {:ok, []}
    end

    def handle_call({:readstate}, _from, state) do
        {:reply, state, state}
    end

    def handle_call({:readmap, index, bound}, _from, state) do
        rtnmap = %{}
        if index - 1 >= 0 do
            rtnmap = Map.merge(rtnmap, Enum.at(state, index - 1))
        end
        if index - bound >= 0 do
            rtnmap = Map.merge(rtnmap, Enum.at(state, index - bound))
        end
        if index - 1 >= 0 do
            rtnmap = Map.merge(rtnmap, Enum.at(state, Enum.random(0..(index-1))))
            rtnmap = Map.merge(rtnmap, Enum.at(state, Enum.random(0..(index-1))))
            rtnmap = Map.merge(rtnmap, Enum.at(state, Enum.random(0..(index-1))))
            rtnmap = Map.merge(rtnmap, Enum.at(state, Enum.random(0..(index-1))))
            rtnmap = Map.merge(rtnmap, Enum.at(state, Enum.random(0..(index-1))))
            rtnmap = Map.merge(rtnmap, Enum.at(state, Enum.random(0..(index-1))))
        end
        {:reply, rtnmap, state}  
    end

    def handle_call({:readpid, index}, _from, state) do
        if index < 0 do
            rtn = 0
        else 
            rtn = Enum.at(state, index)
            [rtn] = Map.values(rtn)
        end
        {:reply, rtn, state}     
    end

    def handle_cast({:finish, key}, state) do
#        IO.inspect state
        [lastkey] = Map.keys(List.last(state))
        if key == lastkey do
            IO.inspect "end"
        end
        {:noreply, state}
    end

    def handle_cast({:write, input}, state) do

        {:noreply, state ++ [input]}
    end

    def handle_cast({:init, input}, state) do

        {:noreply, state}
    end




end