defmodule Project4_server_pid do
    use GenServer

    def handle_call(:readstate, _from, state) do
        {:reply, state, state}
    end
    
    def handle_call(:readlength, _from, state) do
        {:reply, length(state), state}
    end

    def handle_call({:readpid, email}, _from, state) do
        index = Enum.find_index(state, fn(x) -> 
        hd(tl(x)) == email
        end)
        pid = hd(Enum.at(state, index))

        {:reply, pid, state}
    end

    def handle_cast({:writepid, pid, email}, state) do
#        IO.inspect state
        {:noreply, state ++ [[pid, email, 0]]}
    end

    def handle_call(:random, _from, state) do
        random = Enum.random(state)
        {:reply, random, state}    
    end

    def handle_call({:checkstate, pid}, _from, state) do
        index = Enum.find_index(state, fn(x) -> List.first(x) == pid end)
        value = Enum.at(state, index)
        [pidtemp, emailtemp, statetemp] = value
#        if statetemp == 0 do
#            IO.inspect "logoff user"
#        end
        {:reply, statetemp, state}
    end

    def handle_cast({:logoff, offpid}, state) do
        index = Enum.find_index(state, fn(x) -> List.first(x) == offpid end)
        value = Enum.at(state, index)
        [pidtemp, emailtemp, statetemp] = value
        state = List.replace_at(state, index, [offpid, emailtemp, 0])
        {:noreply, state}
    end

    def handle_cast({:login, pid}, state) do
        index = Enum.find_index(state, fn(x) -> List.first(x) == pid end)
        value = Enum.at(state, index)
        [pidtemp, emailtemp, statetemp] = value
        state = List.replace_at(state, index, [pid, emailtemp, 1])
        {:noreply, state}
    end

    def handle_cast({:logintest, pid}, state) do
        index = Enum.find_index(state, fn(x) -> List.first(x) == pid end)
        value = Enum.at(state, index)
        [pidtemp, emailtemp, statetemp] = value
        state = List.replace_at(state, index, [pid, emailtemp, 1])
        {:noreply, state}
    end

    def handle_call(:logofftest, _from, state) do
        random = Enum.random(state)
        [pidtemp, emailtemp, statetemp] = random
        index = Enum.find_index(state, fn(x) -> List.first(x) == pidtemp end)
        state = List.replace_at(state, index, [pidtemp, emailtemp, 0])
        {:noreply, state}
    end
end
  