defmodule Project4_server_tweet do
    use GenServer

    def handle_call(:readstate, _from, state) do
        {:reply, state, state}
    end
    
    def handle_call(:random, _from, state) do
        {:reply, Enum.random(state), state}
    end

    def handle_call({:gettweets, email, potentialusers}, _from, state) do
#        IO.inspect "F"
        tweets = Enum.filter(state, fn(element) ->                   #get his own tweets
            [emailtemp, _, _, _, _, _] = element
            Enum.member?(potentialusers, emailtemp)
            end)
#        IO.inspect "GETTWEETS"
#        IO.inspect tweets
        {:reply, tweets, state}
    end

    def handle_call({:tweet, tweet}, _from, state) do

#        [email, tweetcontent, mention, hashtag, retweet, timestamp] = tweet
        [email, tweetcontent, mention, hashtag, retweet] = tweet
        
        mention = Regex.scan(~r/@\S+/, tweetcontent)
        hashtag = Regex.scan(~r/#\S+/, tweetcontent)

        hashindex = GenServer.call(:global.whereis_name(:tweetnumber), :readstate)
        GenServer.cast(:global.whereis_name(:tweetnumber), :add)

#        tweet = [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex]
        tweet = [email, tweetcontent, mention, hashtag, retweet, hashindex]
        
        followed = GenServer.call(:global.whereis_name(:usertable), {:readfollowed, email}) 
        mapemails = followed ++ [email]
#        IO.inspect "MAPEMAILS"
#        IO.inspect mapemails
        GenServer.cast(:global.whereis_name(:tweetmap), {:write, mapemails, tweet})
        
        tweetfollowed(followed, [tweet])
        {:reply, [tweet], [tweet] ++ state}
    end

    def handle_call({:retweet, tweet}, _from, state) do
#        [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex] = tweet
        [email, tweetcontent, mention, hashtag, retweet, hashindex] = tweet

        if is_nil(retweet) do
            retweet = hashindex
            hashindex = GenServer.call(:global.whereis_name(:tweetnumber), :readstate)
            GenServer.cast(:global.whereis_name(:tweetnumber), :add)
        else
            hashindex = GenServer.call(:global.whereis_name(:tweetnumber), :readstate)
            GenServer.cast(:global.whereis_name(:tweetnumber), :add)
        end
#        tweet = [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex]
        tweet = [email, tweetcontent, mention, hashtag, retweet, hashindex]
        
        followed = GenServer.call(:global.whereis_name(:usertable), {:readfollowed, email})
        
        tweetfollowed(followed, [tweet])        
        {:reply, [tweet], [tweet] ++ state}
    end

    def handle_call({:query, method, argument}, _from, state) do
        case method do
            "queryhashtag" ->
                rtnquery = Enum.filter(state, fn(element) ->
#                    [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex] = element
                    [email, tweetcontent, mention, hashtag, retweet, hashindex] = element
                    Enum.member?(hashtag, ["#"<>argument])
                    end)
            "querymention" ->
                rtnquery = Enum.filter(state, fn(element) ->
 #                   [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex] = element
                    [email, tweetcontent, mention, hashtag, retweet, hashindex] = element
                    Enum.member?(mention, ["@"<>argument])
                    end)
            "queryretweet" ->
                rtnquery = Enum.filter(state, fn(element) ->
#                    [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex] = element
                    [email, tweetcontent, mention, hashtag, retweet, hashindex] = element
                    !is_nil(retweet)
                    end)     
            "querysubscribe" ->
                rtnquery = Enum.filter(state, fn(element) ->
#                    [email, tweetcontent, mention, hashtag, retweet, timestamp, hashindex] = element
                    [email, tweetcontent, mention, hashtag, retweet, hashindex] = element                   
                    email == argument
                    end)                 
        end
        {:reply, rtnquery, state}
    end

    def tweetfollowed([], tweet) do
        
    end

    def tweetfollowed(followed, tweet) do
        clientpid = GenServer.call(:global.whereis_name(:pidtable), {:readpid, hd(followed)})
        if GenServer.call(:global.whereis_name(:pidtable), {:checkstate, clientpid}) == 1 do
            GenServer.cast(clientpid, {:pushtweet, tweet})       
        end
        tweetfollowed(tl(followed), tweet)
    end

    def handle_call(:test, _from, state) do
        
        {:reply, "YESR", state}
    end

end
  