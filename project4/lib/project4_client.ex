defmodule Project4_client do
    use GenServer
#    import Ecto.Query
#    @ServerName :CenterServer
#   state is user state username email password
    def main(argv) do
#        mainloop()
    end
    
    def handle_call(:readstate, _from, state) do
        
        {:reply, state, state}
    end

    def handle_call({:register, user}, _from, state) do
#        IO.inspect :global.whereis_name(:usertable)
        GenServer.call(:global.whereis_name(:usertable), {:register, user})

        {:reply, user, user ++ [[]]}
    end

    def handle_cast({:login, user}, state) do
        tweets = GenServer.call(:global.whereis_name(:usertable), {:login, user})
        if tweets == false do
            tweets = []
        end
        pidtablepid = :global.whereis_name(:pidtable)
        if !is_nil(tweets) do
            GenServer.cast(pidtablepid, {:login, self()})         
        end
        [username, emailaddress, password, subscribe, followed, tweetso] = state
        tweets = tweetso ++ tweets
        state = [username, emailaddress, password, subscribe, followed, tweets]
        {:noreply, state}
    end

    def handle_cast(:logoff, state) do
        [username, email, password, subscribe, followed, tweets] = state
        GenServer.cast(:global.whereis_name(:pidtable), {:logoff, self()})
        tweets = []
        state = [username, email, password, subscribe, followed, tweets]
        {:noreply, state}
    end

    def handle_call({:subscribe, email}, _from, state) do
        [username, emailaddress, password, subscribe, followed, tweets] = state                 #subscribe list updated
#        IO.inspect subscribe
        if !Enum.member?(subscribe, email) do
            if emailaddress != email do
#                subscribe = subscribe ++ [email]
#                state = [username, emailaddress, password, subscribe, followed]
#                GenServer.call(:global.whereis_name(:usertable), {:update, state})
                GenServer.call(:global.whereis_name(:usertable), {:update_subscribe, emailaddress, email})
                                                                                        #folloewed list updated
                GenServer.call(:global.whereis_name(:usertable), {:update_followed, email, emailaddress})
            end
        end
 
        {:reply, state, state}    
    end

    def handle_cast({:init}, state) do
        {:noreply, state}
    end

    def handle_cast({:writepid, clientpid}, state) do
        {:noreply, state ++ [clientpid]}
    end

    def handle_cast({:tweet, tweet}, state) do
        [username, email, password, subscribe, followed, tweets] = state
        tweet = tweet                               #hashtag mention
        hashtag = nil
        mention = nil
        retweet = nil
        timestamp = :calendar.universal_time()
        tweettemp = [email, tweet, hashtag, mention, retweet, timestamp]

        tweettablepid = :global.whereis_name(:tweettable)

        rtntweet = GenServer.call(tweettablepid, {:tweet, tweettemp})              
        tweets = tweets ++ rtntweet
        state = [username, email, password, subscribe, followed, tweets]
        {:noreply, state}
    end

    def handle_cast({:retweet, tweet}, state) do
        [username, email, password, subscribe, followed, tweets] = state
        [emailt, tweetcontentt, mentiont, hashtagt, retweett, timestampt, hashindext] = tweet
        tweet = [email, tweetcontentt, mentiont, hashtagt, retweett, timestampt, hashindext]
        rtntweet = GenServer.call(:global.whereis_name(:tweettable), {:retweet, tweet})
        tweets = tweets ++ rtntweet
        state = [username, email, password, subscribe, followed, tweets]
        {:noreply, state}
    end

    def handle_cast({:pushtweet, tweet}, state) do
        [username, emailaddress, password, subscribe, followed, tweets] = state
        tweets = tweets ++ tweet
        {:noreply, state}
    end

    def handle_cast({:query, method, argument}, state) do
        rtnquery = GenServer.call(:global.whereis_name(:tweettable), {:query, method, argument})
        rtnlength = length(rtnquery)
        IO.inspect rtnquery
        IO.inspect Integer.to_string(rtnlength) <> " tweets found in total " <> Integer.to_string(GenServer.call(:global.whereis_name(:tweetnumber), :readstate)) <> " tweets"
        {:noreply, state}
    end

  end   
  