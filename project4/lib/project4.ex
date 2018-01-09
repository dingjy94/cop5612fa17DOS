defmodule Project4 do
    use GenServer
    @usernumber 100
    @zipf_s 1
    @hashtagnumber 1
    @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])
    @sleeptime 1

    def main(argv) do
#        IO.inspect argv
        [clientnumber, method, argument] = argv
        clientnumber = String.to_integer(clientnumber)
        {:ok, usertablepid} = GenServer.start_link(Project4_server, [])
        {:ok, tweettablepid} = GenServer.start_link(Project4_server_tweet, [])
        {:ok, pidtablepid} = GenServer.start_link(Project4_server_pid, [])
        {:ok, tweetnumberpid} = GenServer.start_link(Project4_server_tweet_number, 0)
        {:ok, tweetmappid} = GenServer.start_link(Project4_server_tweetmap, %{})
  #      IO.inspect tweettablepid
        :global.register_name(:usertable, usertablepid)
        :global.register_name(:tweettable, tweettablepid)
        :global.register_name(:pidtable, pidtablepid)
        :global.register_name(:tweetnumber, tweetnumberpid)
        :global.register_name(:tweetmap, tweetmappid)

        zifpconstant = 1/getzipfconstant()
#        clientnumber = clientnumber
        logoffnumber = round(clientnumber / 10)  
#        logoffnumber = 1

        init_client(clientnumber)
        register_client(clientnumber)
        subscribe_client(clientnumber, zifpconstant, clientnumber)


        login_client(clientnumber)
 
#        spawn(fn() -> logofflooptest(logoggnumber) end)
        spawn(fn() -> logoffloop(logoffnumber) end)    
#        spawn(fn() -> loginofftest(logoffnumber) end)
        tweet_client(clientnumber)        
 
        spawn(fn() -> tweetloop() end)
        spawn(fn() -> retweetloop() end)
      
        if method == "querysubscribe" || method == "queryhashtag" || method == "querymention" || method == "queryretweet" do
            spawn(fn() -> queryloop(method, argument, System.system_time(:second)) end)
        end
        mainloop(method, argument, 100, logoffnumber)
    end


    def init_client(0) do
        usertablepid = :global.whereis_name(:usertable)
        GenServer.call(usertablepid, :readstate)
        IO.inspect "all user process init"
    end

    def init_client(clientnumber) do
        pidtablepid  = :global.whereis_name(:pidtable)
        {:ok, clientpid} = GenServer.start_link(Project4_client, [])
        GenServer.cast(pidtablepid, {:writepid, clientpid, "client" <> Integer.to_string(clientnumber) <> "@gmail.com"})
        init_client(clientnumber - 1)
    end

    def register_client(0) do
        IO.inspect "register done"
    end

    def register_client(clientnumber) do

        usertablepid = :global.whereis_name(:usertable)
        pidtablepid  = :global.whereis_name(:pidtable)
        [clientpid, email, statetemp] = Enum.at(Enum.reverse(GenServer.call(pidtablepid, :readstate)), clientnumber - 1)
#        IO.inspect clientpid
        user = ["client" <> Integer.to_string(clientnumber), "client" <> Integer.to_string(clientnumber) <> "@gmail.com", "ABCDEFG", [], []]
        GenServer.call(clientpid, {:register, user})

        register_client(clientnumber - 1)
    end

    def tweet_client(0) do
        IO.inspect "init tweets done"
    end
 
    def tweet_client(clientnumber) do
        :timer.sleep(@sleeptime)
        pidtablepid  = :global.whereis_name(:pidtable)
        [clientpid, email,  statetemp] = Enum.at(Enum.reverse(GenServer.call(pidtablepid, :readstate)), clientnumber - 1)
        if statetemp == 1 do
            number = GenServer.call(:global.whereis_name(:pidtable), :readlength)
            randomnumber = Enum.random(1..number)
            user = ["client" <> Integer.to_string(clientnumber), "client" <> Integer.to_string(clientnumber) <> "@gmail.com", "ABCDEFG", [], []]
            GenServer.cast(clientpid, {:tweet, "hello this is" <>  " client" <> Integer.to_string(clientnumber) <> " @client" <> Integer.to_string(randomnumber) <> " #" <> randstring(@hashtagnumber) <> " "})
        end
        tweet_client(clientnumber - 1)
    end   

    def subscribe_client(0, zipf_c, totalnumber) do
#        IO.inspect GenServer.call(:global.whereis_name(:usertable), :readstate)
        IO.inspect "subscribe done"
    end

    def subscribe_client(clientnumber, zipf_c, totalnumber) do
        subscribers_number = round(zipf_c / clientnumber * totalnumber)
#        IO.inspect subscribers_number
        pidtablepid  = :global.whereis_name(:pidtable)
        randomuser = GenServer.call(pidtablepid, :readstate)
        reverse = Enum.reverse(randomuser)

        random_subscribers(subscribers_number, reverse, clientnumber)

#       IO.inspect clientnumber 
        subscribe_client(clientnumber - 1, zipf_c, totalnumber)
    end

    def random_subscribers(0, randomuser, clientnumber) do
    end

    def random_subscribers(number, randomuser, clientnumber) do
 #      IO.inspect randomuser
        [clientpid, _, _] = Enum.at(randomuser, clientnumber - 1)        
        if !is_nil(List.first(randomuser)) do
            if !is_nil(List.first(List.first(randomuser))) do
                [user, useremail, _] = Enum.random(randomuser -- [clientpid])
                clientstate = GenServer.call(clientpid, {:subscribe, useremail})
            end            
        end
        random_subscribers(number - 1, randomuser, clientnumber)
    end

    def login_client(0) do
        IO.inspect "log in done"

    end

    def login_client(clientnumber) do
        :timer.sleep(@sleeptime)
        user = ["client" <> Integer.to_string(clientnumber), "client" <> Integer.to_string(clientnumber) <> "@gmail.com", "ABCDEFG", [], []]
        pidtablepid = :global.whereis_name(:pidtable)       
        [clientpid, emailtemp, statetemp] = Enum.at(Enum.reverse(GenServer.call(pidtablepid, :readstate)), clientnumber - 1)
        if statetemp == 0 do
#            IO.inspect clientnumber
#            IO.inspect emailtemp
#            IO.inspect "login " <> emailtemp
#            IO.inspect clientpid
            GenServer.cast(clientpid, {:login, user})   
        end
        login_client(clientnumber - 1)
    end

    def sendtweet() do
        [pid, email, state] = GenServer.call(:global.whereis_name(:pidtable), :random)
        if state == 1 do
            tweet = getrandomtweet()
            GenServer.cast(pid, {:tweet, tweet})
        end
    end
    
    def retweet() do
        [pid, emailaddress, logstate] = GenServer.call(:global.whereis_name(:pidtable), :random)
        if logstate == 1 do
#            IO.inspect "retweet start"
            tweet = GenServer.call(:global.whereis_name(:tweettable), :random) 
#            IO.inspect "retweet mid"
            GenServer.cast(pid, {:retweet, tweet})  
#            IO.inspect "retweetend"         
        end
    end

    def query(method, argument) do
        [pid, email, state] = GenServer.call(:global.whereis_name(:pidtable), :random)                  #select a random user
        GenServer.cast(pid, {:query, method, argument})
    end

    def loginpidlist([]) do
#        IO.inspect "FINISH"
    end

    def loginpidlist(pidlist) do
        :timer.sleep(@sleeptime)
        if !Process.alive?(hd(hd(pidlist))) do
            IO.inspect "ERROR"
        end
        [pidtemp, emailtemp, statetemp] = hd(pidlist)
        user = GenServer.call(:global.whereis_name(:usertable), {:getuser,emailtemp})
        GenServer.cast(pidtemp, {:login, user})
        loginpidlist(tl(pidlist))
    end

    def logoff(0, logoffnumber, pidlist) do
        :timer.sleep(@sleeptime)
#        IO.inspect "PIDLIST "
#        IO.inspect pidlist
        loginpidlist(pidlist)
    end

    def logoff(number, logoffnumber, pidlist) do
        :timer.sleep(@sleeptime)
        rtn = GenServer.call(:global.whereis_name(:pidtable), :random)
        [pid, email, state] = rtn
        if state == 1 do
            GenServer.cast(pid, :logoff)
            pidlist = pidlist ++ [rtn]
        end
        logoff(number - 1, logoffnumber, pidlist)
    end

    def loginofftest(number) do
        pidlist = logofftest(number, [])
        :timer.sleep(@sleeptime)       
        logintest(pidlist)
        loginofftest(number)
    end

    def logintest([]) do

    end

    def logintest(pidlist) do
        GenServer.cast(:global.whereis_name(:pidtable), {:logintest, hd(pidlist)})
        logintest(tl(pidlist))
    end

    def logofftest(0, pidlist) do
        pidlist
    end

    def logofftest(number, pidlist) do
        rtn = GenServer.call(:global.whereis_name(:pidtable), :logofftest)
        pidlist = pidlist ++ [rtn]
        logofftest(number - 1, pidlist)
    end

    def getrandomtweet() do
        number = GenServer.call(:global.whereis_name(:pidtable), :readlength)
        randomnumber = Enum.random(1..number)
        tweet = "I am sending a tweet to " <> "@client" <> Integer.to_string(randomnumber) <> " #" <> randstring(@hashtagnumber) <>" "
        tweet
    end

   
    def randstring(count) do
        :rand.seed(:exsplus, :os.timestamp())
        Stream.repeatedly(&random_char_from_alphabet/0)
        |> Enum.take(count)
        |> List.to_string()
    end

    defp random_char_from_alphabet() do
        Enum.random(@alphabet)
    end

    def getconstant(0) do
        0
    end

    def getconstant(number) do   
        rtn = getconstant(number - 1) + :math.pow((1/number), @zipf_s)
        rtn
    end

    def getzipfconstant() do
        rtn = getconstant(@usernumber)
        rtn
    end


    def tweetloop() do
        sendtweet()
        :timer.sleep(@sleeptime)
        tweetloop()
    end


    def retweetloop() do
        retweet()
        :timer.sleep(@sleeptime)
        retweetloop()
    end

    def logoffloop(logoffnumber) do
        logoff(logoffnumber, logoffnumber, [])

        logoffloop(logoffnumber)
    end


    def queryloop(method, argument, time) do
        IO.inspect "Time spent " <> Integer.to_string(System.system_time(:second) - time) <> "s"
        query(method, argument)
        :timer.sleep(5000)
        
#        IO.inspect length(GenServer.call(:global.whereis_name(:tweettable), :readstate))
        queryloop(method, argument, time)
    end

    def mainloop(method, argument, count, logoffnumber) do

        mainloop(method, argument, count + 1, logoffnumber)
    end

end
