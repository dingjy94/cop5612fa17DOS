defmodule Project4_server_tweet_number do
    use GenServer

    def handle_call(:readstate, _from, state) do
        {:reply, state, state}
    end
    

    def handle_cast(:add, state) do
        state = state + 1
        {:noreply, state}
    end


end
  