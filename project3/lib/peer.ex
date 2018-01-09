defmodule Peer do
    use GenServer
    @b 16
    @l 16
    def start_link(opts \\[0] )do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        {:ok, %{:L =>%{:sha=>[[],[]], :hashmap=>%{}}, :R =>%{:sha=>[], :hashmap=>%{}}, :M=>%{:sha=>[], :hashmap=>%{}}, :peersha=>%{:sha=>[], :hashmap=>%{}}, :serverpid => nil}}
    end

    def handle_call({:readstate, key}, _from, state) do
        {:reply, state, state}  
    end

    def handle_call({:readpid, key}, _from, state) do
        {:ok, tempR} = Map.fetch(state, :R)
        {:ok, tempL} = Map.fetch(state, :L)
        {:ok, tempM} = Map.fetch(state, :M)
        {:ok, tempRt} = Map.fetch(tempR, :sha)
        {:ok, tempLt} = Map.fetch(tempL, :sha)
        {:ok, tempMt} = Map.fetch(tempM, :sha)

        cond do
            Enum.member?(tempLt, key) -> 
            {:ok, pid} = Map.fetch(tempL, :hashmap)
            {:ok, pid} = Map.fetch(pid, key)
            Enum.member?(tempRt, key) ->
            {:ok, pid} = Map.fetch(tempR, :hashmap)
            {:ok, pid} = Map.fetch(pid, key)
            Enum.member?(tempMt, key) ->
            {:ok, pid} = Map.fetch(tempM, :hashmap)
            {:ok, pid} = Map.fetch(pid, key)
        end
        {:reply, pid, state}     
    end

    def route(msg, type, key, laststate, state) do
        {:ok, laststateR} = Map.fetch(laststate, :R)
        {:ok, laststateL} = Map.fetch(laststate, :L)
        {:ok, laststateM} = Map.fetch(laststate, :M)
        {:ok, spid} = Map.fetch(laststate, :serverpid)
        {:ok, laststatep} = Map.fetch(laststate, :peersha)

        {:ok, tempR} = Map.fetch(state, :R)
        {:ok, tempL} = Map.fetch(state, :L)
        {:ok, tempM} = Map.fetch(state, :M)
        {:ok, tempp} = Map.fetch(state, :peersha)

        {:ok, tempRt} = Map.fetch(tempR, :sha)
        {:ok, tempLt} = Map.fetch(tempL, :sha)
        {:ok, tempMt} = Map.fetch(tempM, :sha)
        {:ok, temppt} = Map.fetch(tempp, :sha)

        {:ok, templp} = Map.fetch(laststate, :peersha)
#        IO.inspect "test"
#        IO.inspect "key"
#        IO.inspect key
#        IO.inspect templp
        {:ok, templpt} = Map.fetch(templp, :hashmap)
        {:ok, templpt} = Map.fetch(templpt, key)                #origin key pid
        pid = 0
        leaflist = hd(tempLt) ++ hd(tl(tempLt))
#        IO.inspect "test"
#        IO.inspect temppt
#        IO.inspect key
        if Enum.member?(leaflist, key) do 
                IO.inspect "case1"
                {:ok, pid} = Map.fetch(tempL, :hashmap)
                {:ok, pid} = Map.fetch(pid, key)
                    case type do
                        "route" ->
                            laststate = %{:L =>tempL, :R => laststateR, :M => tempM, :peersha => laststatep, :serverpid => spid}
                            type = "forward"
                            GenServer.cast(pid, {:hear, msg, type, key, laststate})
                        "deliver" -> 
                            laststate = %{:L =>tempL, :R => laststateR, :M => laststateM, :peersha => laststatep, :serverpid => spid}
                            type = "forward"
                            GenServer.cast(pid, {:hear, msg, type, key, laststate}) 
                    end
        else
            [tempsha] = temppt
            prefix = get_prefix(key, tempsha)
            {column, ""} = Integer.parse((String.at(key, prefix)), 16)
            hashindex = prefix * @b + column
#            IO.inspect key
#            IO.inspect tempsha
#            IO.inspect hashindex
#            IO.inspect Enum.at(tempRt, hashindex)
#            IO.inspect Enum.at(tempRt, hashindex) != 0
            hashsha = Enum.at(tempRt, hashindex)
#            IO.inspect "hashsha"
#            IO.inspect tempRt
#            IO.inspect hashindex
#            IO.inspect hashsha
#            IO.inspect "hashshaend"
            if hashsha != 0 do
 #               IO.inspect "case2"
                {:ok, pid} = Map.fetch(tempR, :hashmap)
                {:ok, pid} = Map.fetch(pid, hashsha)
#                IO.inspect key
#                IO.inspect hashsha
                case type do
                    "route" ->
                        laststateR = modify_routetable(laststateR, tempR, prefix)
                        laststate = %{:L =>tempL, :R => laststateR, :M => tempM, :peersha => laststatep, :serverpid => spid}
                        type = "deliver"
                        if hashsha == key do
                            type = "forward" 
                        end
                        GenServer.cast(pid, {:hear, msg, type, key, laststate})
                    "deliver" -> 
                        laststateR = modify_routetable(laststateR, tempR, prefix)
                        laststate = %{:L =>tempL, :R => laststateR, :M => laststateM, :peersha => laststatep, :serverpid => spid}
                        type = "deliver"
                        if hashsha == key do
                            type = "forward"
                        end
#                        IO.inspect type
#                        IO.inspect hashsha
#                        IO.inspect key
#                        IO.inspect pid
#                        IO.inspect self()
                        GenServer.cast(pid, {:hear, msg, type, key, laststate}) 
                end  
            else 
 #              IO.inspect "case3"
                case type do
                    "route" -> 
 #                       IO.inspect "case3 A"
                        [diff, clkey, tnumber, _, _, pid, type] = find_closest(key, tempR, tempL, tempM, tempp, prefix)
 #                       IO.inspect "forward1"
 #                       IO.inspect pid
                        if type == "forward" do
#                            IO.inspect "case3 AA"
                            laststateM = tempM
                            pid = templpt
 #                           IO.inspect pid
                        end             
 #                       IO.inspect type
                        laststate = %{:L =>tempL, :R => laststateR, :M => tempM, :peersha => laststatep, :serverpid => spid}
                        GenServer.cast(pid, {:hear, msg, type, key, laststate})   
                    "deliver" ->
 #                       IO.inspect "case3 B"
                        [diff, clkey, tnumber, _, _, pid, type] = find_closest(key, tempR, tempL, tempM, tempp, prefix)
                        if type == "forward" do
                            laststateM = tempM
                            pid = templpt
                        end           

#                        IO.inspect type
                        laststate = %{:L =>tempL, :R => laststateR, :M => laststateM, :peersha => laststatep, :serverpid => spid}
                        GenServer.cast(pid, {:hear, msg, type, key, laststate}) 
                end
            end
        end 

    end

    def find_closest(key, tempR, tempL, tempM, tempp, prefix) do          #tempp current node     tempRLM origin node
        targetnumber = get_number(key)
#        IO.inspect targetnumber
        {:ok, currentcloest} = Map.fetch(tempp, :sha)
        {:ok, currentpid} = Map.fetch(tempp, :hashmap)

#        IO.inspect currentpid
        {:ok, currentpid} = Map.fetch(currentpid, hd(currentcloest))

        currentcloest = hd(currentcloest)
 #       IO.inspect currentcloest
        currentnumber = get_number(currentcloest)

        input = [abs(currentnumber - targetnumber), currentcloest, targetnumber, key, prefix]
        input = check_list(input, tempR)
        currentpid = updatepid(tempR, input, currentpid)

        input = check_Leaf_list(input, tempL)
        currentpid = updatepid(tempL, input, currentpid)

        input = check_list(input, tempM)
        currentpid = updatepid(tempM, input, currentpid)
        
        [diff, key, tnumber, _, _] = input
        input = input ++ [currentpid]
#        IO.inspect "pid"
#        IO.inspect currentpid
#        IO.inspect "self()"
#        IO.inspect self()
        if key == currentcloest do      # this node is the closest node
#            IO.inspect "forwardA"
            rtn = input ++ ["forward"]
        else
#            IO.inspect "forwardB"
            rtn = input ++ ["deliver"]
        end

    end

    def re_route(msg, type, key, state) do
        {:ok, tempL} = Map.fetch(state, :L)
        {:ok, tempL} = Map.fetch(tempL, :hashmap)
        {:ok, tempM} = Map.fetch(state, :M)
        {:ok, tempM} = Map.fetch(tempM, :hashmap)        
        {:ok, tempR} = Map.fetch(state, :R)
        {:ok, tempR} = Map.fetch(tempR, :hashmap)
        temp = Map.merge(tempL, tempR)
        temp = Map.merge(temp, tempM)
        templist = Map.values(temp)
        re_route_send(msg, type, key, templist)
    end

    def re_route_send(msg, type, key, []) do
    end

    def re_route_send(msg, type, key, templist) do
        GenServer.cast(hd(templist), {:reroute, key, self()})
#        rtn = GenServer.call(hd(templist), {:reroute, key, self()})
        re_route_send(msg, type, key, tl(templist))
    end

    def modify_routetable(laststateR, tempR, prefix) do
#        IO.inspect "modify"
#        IO.inspect laststateR
#        IO.inspect "modified"
        laststateR = update_routesha(laststateR, tempR, prefix, @b)
#        IO.inspect laststateR
        laststateR
    end

    def update_routesha(laststateR, tempR, prefix, 0) do
        laststateR
    end
    
    def update_routesha(laststateR, tempR, prefix, index) do
        laststateR = update_routesha(laststateR, tempR, prefix, index - 1)
        {:ok, lsR} = Map.fetch(laststateR, :sha) 
        {:ok, tR} = Map.fetch(tempR, :sha)
        tR_element = Enum.at(tR, prefix * @b + index)
        if tR_element != 0 do
            lsR = List.replace_at(lsR, prefix * @b + index, tR_element)  
            {:ok, tR_hashmap} = Map.fetch(tempR, :hashmap)
            {:ok, tR_hashmap_pid} = Map.fetch(tR_hashmap, tR_element)
            {:ok, lsR_hashmap} = Map.fetch(laststateR, :hashmap)
            lsR_hashmap = Map.put(lsR_hashmap, tR_element, tR_hashmap_pid) 
            laststateR = %{:sha => lsR, :hashmap => lsR_hashmap}
        end
        laststateR
    end

    def updatepid(inputlist, input, currentpid) do 
        {:ok, tlist} = Map.fetch(inputlist, :hashmap)
        [_, key, _, _, _] = input
        if Map.has_key?(tlist, key) do
            {:ok, currentpid} = Map.fetch(tlist, key)
        end
        currentpid
    end

    def check_element(input, []) do
        input
    end

    def check_element(input, tlist) do
        [diffierence, key, targetnumber, originkey, prefix] = check_element(input, tl(tlist))
        rtn = [diffierence, key, targetnumber, originkey, prefix]
        if hd(tlist) != 0 do
            if diffierence > abs(targetnumber - get_number(hd(tlist))) && get_prefix(originkey, hd(tlist)) >= prefix do
                diffierence = abs(targetnumber - get_number(hd(tlist)))
                rtn = [diffierence, hd(tlist), targetnumber, originkey, prefix]
            end
        end
        rtn
    end

    def check_Leaf_list(input, templist) do
        {:ok, tlist} = Map.fetch(templist, :sha)
        tlist = hd(tlist) ++ hd(tl(tlist))
#        IO.inspect tlist
        input = check_element(input, tlist)
        input
    end

    def check_list(input, templist) do
        {:ok, tlist} = Map.fetch(templist, :sha)
        input = check_element(input, tlist)
        input
    end

    def get_number(key) do
        {number, ""} = Integer.parse(key, 16)
        number
    end

    def get_prefix(str1, str2, index) do
        if String.at(str1, index) == String.at(str2, index) do
            rtn = get_prefix(str1, str2, index + 1) + 1
        else 
            rtn = 0
        end
        rtn
    end

    def get_prefix(str1, str2) do
        rtn = get_prefix(str1, str2, 0)
        rtn
    end

    def update_routemap(tempR, shatemp, pid, shatempneighbour, gpid) do
        {:ok, routetable} = Map.fetch(tempR, :sha)
        {:ok, routemap} = Map.fetch(tempR, :hashmap)
        prefix = get_prefix(shatemp, shatempneighbour)
        {column, ""} = Integer.parse((String.at(shatempneighbour, prefix)), 16)
        hashindex = prefix * @b + column
        if Enum.at(routetable, hashindex) == 0 do
#            IO.inspect "unpdate r"
            routetable = List.replace_at(routetable, hashindex, shatempneighbour)
            routemap = Map.put(routemap, shatempneighbour, gpid)
#            IO.inspect routemap
        end
        rtn = %{:sha => routetable, :hashmap => routemap}
        rtn
    end

    def handle_call({:readstate}, _from, state) do
        {:reply, state, state}
    end

    def handle_cast({:reroute, sha, pid}, state) do
 #       IO.inspect "reroute"
        {:ok, tempL} = Map.fetch(state, :L)
        {:ok, tempM} = Map.fetch(state, :M)
        {:ok, tempR} = Map.fetch(state, :R)
        {:ok, spid} = Map.fetch(state, :serverpid)
        {:ok, tempP} = Map.fetch(state, :peersha)
        {:ok, tempPP} = Map.fetch(tempP, :sha)
        [tempPP] = tempPP
        newLeafSet = Project3.newLeafs(tempL, tempPP, self(), sha, pid)
        newRouteTable = update_routemap(tempR, tempPP, self(), sha, pid)
        state = %{:L => newLeafSet, :M =>tempM, :R => newRouteTable, :peersha => tempP, :serverpid => spid}
 #       IO.inspect newRouteTable
 #       IO.inspect state                               #############################3inspect output
        {:noreply, state}
    end

    def handle_call({:reroute, sha, pid}, _from, state) do
 #       IO.inspect "reroute"
        {:ok, tempL} = Map.fetch(state, :L)
        {:ok, tempM} = Map.fetch(state, :M)
        {:ok, tempR} = Map.fetch(state, :R)
        {:ok, spid} = Map.fetch(state, :serverpid)
        {:ok, tempP} = Map.fetch(state, :peersha)
        {:ok, tempPP} = Map.fetch(tempP, :sha)
        [tempPP] = tempPP
        newLeafSet = Project3.newLeafs(tempL, tempPP, self(), sha, pid)
        newRouteTable = update_routemap(tempR, tempPP, self(), sha, pid)
        state = %{:L => newLeafSet, :M =>tempM, :R => newRouteTable, :peersha => tempP, :serverpid => spid}
 #       IO.inspect newRouteTable
 #       IO.inspect state                               #############################3inspect output
        {:reply, 0, state}
    end



    def handle_call({:hear, msg, type, key, laststate}, _from, state) do
        case msg do
        "join" -> 
            if type == "forward" do
#                IO.inspect "laststate"
#                IO.inspect laststate
#                IO.inspect "state"
#                IO.inspect state
                IO.inspect self()
                state = add_state(state, laststate)
                re_route(msg, type, key, state)

                {:ok, spid} = Map.fetch(state, :serverpid)
                GenServer.cast(spid, {:finish, key})
#                IO.inspect "routeback"
#                IO.inspect key
#                IO.inspect "state"
#                IO.inspect state
#                IO.inspect "laststate"
#               IO.inspect laststate
#                IO.inspect "addstate"
#               IO.inspect add_state(state, laststate)
            else 
#                IO.inspect "route"
                route(msg, type, key, laststate, state)
            end
        end
        {:reply, 0, state}
    end





    def handle_cast({:hear, msg, type, key, laststate}, state) do
        case msg do
        "join" -> 
            if type == "forward" do
#                IO.inspect "laststate"
#                IO.inspect laststate
#                IO.inspect "state"
#                IO.inspect state
                state = add_state(state, laststate)
                re_route(msg, type, key, state)
                IO.inspect self()
                {:ok, spid} = Map.fetch(state, :serverpid)
                GenServer.cast(spid, {:finish, key})
#                IO.inspect "routeback"
#                IO.inspect key
#                IO.inspect "state"
#                IO.inspect state
#                IO.inspect "laststate"
#               IO.inspect laststate
#                IO.inspect "addstate"
#               IO.inspect add_state(state, laststate)
            else 
#                IO.inspect "route"
                route(msg, type, key, laststate, state)
            end
        end
        {:noreply, state}
    end


    def handle_cast({:start, laststate}, state) do
        state = add_state(laststate, state)
#        IO.inspect state
        {:noreply, state}
    end

    def add_hashmap(speersha, inputpeersha) do
        {:ok, shatemp1} = Map.fetch(speersha, :sha)
        {:ok, shatemp2} = Map.fetch(inputpeersha, :sha)
        shatemp = Enum.uniq(Enum.sort(shatemp1 ++ shatemp2))
        {:ok, hashtemp1} = Map.fetch(speersha, :hashmap)
        {:ok, hashtemp2} = Map.fetch(inputpeersha, :hashmap)
        hashtemp = Map.merge(hashtemp1, hashtemp2)
        temp = %{:sha => shatemp, :hashmap => hashtemp}
        temp
    end

    def add_hashmap_L(speersha, inputpeersha) do
        {:ok, shatemp1} = Map.fetch(speersha, :sha)
        {:ok, shatemp2} = Map.fetch(inputpeersha, :sha)
        shatemp1small = hd(shatemp1)
        shatemp1big = hd(tl(shatemp1))
        shatemp2small = hd(shatemp2)
        shatemp2big = hd(tl(shatemp2))
        shatemp1small = Enum.sort(Enum.uniq(shatemp1small ++ shatemp2small))
        shatemp1big = Enum.sort(Enum.uniq(shatemp1big ++ shatemp2big))
        shatemp = [shatemp1small, shatemp1big]
        {:ok, hashtemp1} = Map.fetch(speersha, :hashmap)
        {:ok, hashtemp2} = Map.fetch(inputpeersha, :hashmap)
        hashtemp = Map.merge(hashtemp1, hashtemp2)
        temp = %{:sha => shatemp, :hashmap => hashtemp}
        temp
    end

    def add_hashmap_R(speersha, inputpeersha) do
        {:ok, shatemp1} = Map.fetch(speersha, :sha)
        {:ok, shatemp2} = Map.fetch(inputpeersha, :sha)
        shatemp = Enum.sort(shatemp1 ++ shatemp2)
        {:ok, hashtemp1} = Map.fetch(speersha, :hashmap)
        {:ok, hashtemp2} = Map.fetch(inputpeersha, :hashmap)
        hashtemp = Map.merge(hashtemp1, hashtemp2)
        temp = %{:sha => shatemp, :hashmap => hashtemp}
        temp
    end

    def add_state(laststate, state) do 
        {:ok, inputL} = Map.fetch(laststate, :L)
        {:ok, inputR} = Map.fetch(laststate, :R)
        {:ok, inputM} = Map.fetch(laststate, :M)
        {:ok, spid} = Map.fetch(laststate, :serverpid)
        {:ok, inputpeersha} = Map.fetch(laststate, :peersha)
        {:ok, sL} = Map.fetch(state, :L)
        {:ok, sR} = Map.fetch(state, :R)
        {:ok, sM} = Map.fetch(state, :M)
        {:ok, speersha} = Map.fetch(state, :peersha)
        inputL = add_hashmap_L(inputL, sL)
        inputR = add_hashmap_R(inputR, sR)
        inputM = add_hashmap(inputM, sM)
        inputpeersha = add_hashmap(speersha, inputpeersha)
        state = %{:L => inputL, :R => inputR, :M => inputM, :peersha =>inputpeersha, :serverpid =>spid}
        state
    end

    def handle_cast({:init, input}, state) do
        state = %{:L => [], :R => [], :M => []}
        {:noreply, state}
    end

    def handle_cast({:join, input}, state) do

    end

    def newLeafs(leafSet) do

    end


    def getkeyvalue(key) do
        pid = GenServer.call(self(), {:readpid, key})
#        IO.inspect pid
        pid
    end


end