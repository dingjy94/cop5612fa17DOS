defmodule Project4_server do            #user table
    use GenServer
#    import Ecto.Query 
    def handle_call(:readstate, _from, state) do
        {:reply, state, state}
    end
    
    def handle_call({:register, user}, _from, state) do
        {:reply, state, state ++ [user]}                # add user
    end

    def handle_call({:getuser, email}, _from, state) do
        tableuser = Enum.find(state, fn(element) -> 
            match?([_, ^email, _, _, _], element) end)
        {:reply, tableuser, state}
    end

    def handle_call({:login, user}, _from, state) do
        [username, emailaddress, password, subscribe, followed] = user
        IO.inspect user
        tweets = nil                                                             #check avavilable check user name or email address, should match password
#        tweets = false
 ############
        if is_nil(username) && is_nil(emailaddress) do
            IO.inspect "unvalid username or emailaddress"
        else 
            if !is_nil(username) do
                tableuser = Enum.find(state, fn(element) -> 
                match?([^username, _, ^password, _, _], element) end)
                IO.inspect tableuser
                if !is_nil(tableuser) do
                    pidtablepid = :global.whereis_name(:pidtable)
                    tweettablepid = :global.whereis_name(:tweettable)

                    [username, emailaddress, password, subscribers, followed] = tableuser
                    potentialusers = [emailaddress] ++ subscribers

#                    tweets = GenServer.call(tweettablepid, {:gettweets, emailaddress, potentialusers})
                    tweets = GenServer.call(:global.whereis_name(:tweetmap), {:login, emailaddress})

                    if !is_nil(List.first(tweets)) do
                        IO.inspect "no tweets found"                               #tweets found
                    else 
                        tweets = []
                        IO.inspect "found"                                         #no tweets found
                    end
                end
            end 
        end

        {:reply, tweets, state}
    end



    def handle_call({:update, instate}, _from, state) do  
        [username, email, password, subscribe, followed] = instate 
        index = Enum.find_index(state, fn(element) ->
        match?([_, ^email, _, _, _], element) end)
#        instate = [username, email, password, subscribe, followed]
        state = List.replace_at(state, index, instate)
        {:reply, state, state}
    end

    def handle_call({:update_subscribe, email, subscribe}, _from, state) do
        index = Enum.find_index(state, fn(element) ->
        match?([_, ^email, _, _, _], element) end)      
        value = Enum.at(state, index)
        [usernametemp, emailtemp, passwordtemp, subscribetemp, followedtemp] = value
        if !Enum.member?(subscribetemp, subscribe) do
            subscribetemp = subscribetemp ++ [subscribe]
            value = [usernametemp, emailtemp, passwordtemp, subscribetemp, followedtemp] 
            state = List.replace_at(state, index, value)
        end
        {:reply, state, state}
    end 

    def handle_call({:update_followed, email, followed}, _from, state) do
        index = Enum.find_index(state, fn(element) ->
        match?([_, ^email, _, _, _], element) end)      
        value = Enum.at(state, index)
        [usernametemp, emailtemp, passwordtemp, subscribetemp, followedtemp] = value
        if !Enum.member?(followedtemp, followed) do
            followedtemp = followedtemp ++ [followed]
            value = [usernametemp, emailtemp, passwordtemp, subscribetemp, followedtemp] 
            state = List.replace_at(state, index, value)
        end
        {:reply, state, state}
    end

    def handle_call({:readfollowed, email}, _from, state) do
        index = Enum.find_index(state, fn(element) ->
        match?([_, ^email, _, _, _], element) end)
        value = Enum.at(state, index)
        followed = List.last(value)
        {:reply, followed, state}
    end

end
  