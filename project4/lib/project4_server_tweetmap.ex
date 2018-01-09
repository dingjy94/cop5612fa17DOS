defmodule Project4_server_tweetmap do
    use GenServer

    def handle_call(:readstate, _from, state) do
        {:reply, state, state}
    end

    def handle_cast({:write, emails, tweet}, state) do
        state = writetweetmap(emails, tweet, state)
         {:noreply, state}
    end

    def handle_call({:login, email}, _from, state) do
        if Map.has_key?(state, email) do
            {:ok, statelist} = Map.fetch(state, email)
        else 
            statelist = []         
        end

        {:reply, statelist, state}
    end

    def writetweetmap([], tweet, state) do
        state
    end

    def writetweetmap(emails, tweet, state) do
        if Map.has_key?(state, hd(emails)) do
            {:ok, value} = Map.fetch(state, hd(emails))
            value = [tweet] ++ value 
            state = Map.put(state, hd(emails), value)
        else
            state = Map.put(state, hd(emails), [tweet])
        end
        writetweetmap(tl(emails), tweet, state)
    end
end