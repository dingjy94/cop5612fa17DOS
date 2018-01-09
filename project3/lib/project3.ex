defmodule Project3 do
  @b 16

  def main(argv) do
    [numNodes, numRequests] = argv
    numNodes = String.to_integer(numNodes)
    numRequests = String.to_integer(numRequests)
    {:ok, spid} = Server.start_link()  
    {:ok, srpid} = Serverrtn.start_link()
    GenServer.cast(srpid, {:write, numNodes})
    input = 1
    input = Integer.to_string(input)
    sha = Base.encode16(:crypto.hash(:sha,input))
#    IO.puts sha
    pastryInitLoop(spid, srpid, 0,numNodes, 0)
 #   outstate(spid, numNodes)
    loop(spid)
  end

  def outstate(spid, numNodes) do
    state = GenServer.call(spid, {:readstate})
    
    outstateloop(spid, numNodes - 1)
  end

  def outstateloop(spid, -1) do
  end

  def outstateloop(spid, numNodes) do
    pid = GenServer.call(spid, {:readpid, numNodes})
    IO.inspect GenServer.call(pid, {:readstate})
    outstateloop(spid, numNodes - 1)
  end

  def loop(spid) do
    :timer.sleep(100)
    loop(spid)
  end


  def pastryInit(credentials, application) do
    {:ok, pid} = Peer.start_link()
    [spid, srpid, tpid, index_int, bound] = credentials
    gpid = GenServer.call(spid, {:readpid, index_int - 1})
    indexneighbour = index_int - 1;
    index = Integer.to_string(index_int)
    indexneighbour = Integer.to_string(indexneighbour)
    shatemp = Base.encode16(:crypto.hash(:sha, index))
    shatemp = String.slice(shatemp, 0..31)
    shatempneighbour = Base.encode16(:crypto.hash(:sha, indexneighbour))
    shatempneighbour = String.slice(shatempneighbour, 0..31)
    empty_routetable = init_routetable()
    routemap = init_routemap(empty_routetable, shatemp, pid, shatempneighbour, gpid)
    neighbourmap = init_neighbourmap(spid, index_int, bound)
#    IO.inspect neighbourmap
    tempL = %{:sha => [[],[]], :hashmap => %{}}
    if gpid == 0 do
      state = %{:L => %{:sha =>[[],[]], :hashmap=>%{}}, :R => %{:sha =>empty_routetable, :hashmap=>%{}}, :M => %{:sha=>[],:hashmap=>%{}}, :peersha=>%{:sha=>[shatemp],:hashmap=>%{shatemp => pid}}, :serverpid => srpid}
      GenServer.cast(pid, {:start, state})
    end
    if gpid != 0 do
      newLeafSet = newLeafs(tempL, shatemp, pid, shatempneighbour, gpid)
#      IO.inspect "endlif"
      state = %{:L => newLeafSet, :R => routemap, :M => neighbourmap, :peersha=>%{:sha=>[shatemp],:hashmap=>%{shatemp => pid}}, :serverpid => srpid}
      GenServer.cast(pid, {:start, state})
#      IO.inspect "shatemp"
#      IO.inspect GenServer.call(pid, {:readstate})
#      IO.inspect pid
      route("join", shatemp, gpid, pid)
    end
    GenServer.cast(spid, {:write, %{shatemp => pid}})
    shatemp
  end

  def pastryInitLoop(spid, srpid, index, numNodes, pid) when index == numNodes do
  end

  def pastryInitLoop(spid, srpid, index, numNodes, pid) do
    credentials = [spid, srpid, pid, index, CustomMath.sqrt(numNodes)]
    nodeID = pastryInit(credentials, 0)
#    IO.inspect nodeID
    :timer.sleep(200)
    pastryInitLoop(spid, srpid, index + 1, numNodes, pid)
  end

  def init_routetable() do
    rtn = iroutetable(@b * @b * 2)
  end

  def iroutetable(0) do
    table = []
    table
  end 

  def iroutetable(index) do
    table = iroutetable(index - 1)
    table = table ++ [0]
    table
  end

  def init_routemap(routetable, shatemp, pid, shatempneighbour, gpid) do
    prefix = get_prefix(shatemp, shatempneighbour)
    {column, ""} = Integer.parse((String.at(shatemp, prefix + 1)), 16)
    hashindex = prefix * @b + column
    routetable = List.replace_at(routetable, hashindex, shatempneighbour)
    %{:sha => routetable, :hashmap => %{shatempneighbour => gpid}}
  end

  def init_neighbourmap(spid, index, bound) do
    neighbourmap = GenServer.call(spid, {:readmap, index, bound})
    neighbourmapsha = Map.keys(neighbourmap)
    %{:sha => neighbourmapsha, :hashmap => neighbourmap}
  end

  def deliver(msg, key) do

  end

  def forward(msg, key, nextId) do

  end
  
  def newLeafs(tempL, shatemp, pid, shatempneighbour, gpid) do
#    IO.inspect "leaf"
    {localinteger, ""} = Integer.parse(shatemp, 16)
#    IO.inspect localinteger
    {neighbourinteger, ""} = Integer.parse(shatempneighbour, 16)
    interinteger = :math.pow(2,128) / 2

    {:ok, leafset} = Map.fetch(tempL, :sha)
    {:ok, leafsetmap} = Map.fetch(tempL, :hashmap)
    leafsetsmall = hd(leafset)
    leafsetbig = hd(tl(leafset))
#    IO.inspect localinteger
#    IO.inspect interinteger
    if localinteger - interinteger < 0 do
          if neighbourinteger > localinteger && neighbourinteger < localinteger + interinteger do
                if length(leafsetbig) < @b/2 do
                  leafsetbig = leafsetbig ++ [shatempneighbour]
                  leafsetbig = Enum.sort(leafsetbig)
                  leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                else
                      if shatempneighbour < Enum.at(leafsetbig, -1) do
                        {deletesha, leafsetbig} = List.pop_at(leafsetbig, -1)
                        leafsetbig = leafsetbig ++ [shatempneighbour]
                        leafsetbig = Enum.sort(leafsetbig)
                        leafsetmap = Map.delete(leafsetmap, deletesha)
                        leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                      end
                end
          else
              if length(leafsetsmall) < @b/2 do
                  leafsetsmall = leafsetsmall ++ [shatempneighbour]
                  leafsetsmall = Enum.sort(leafsetsmall)
                  leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
              else
                  farestsha = findfar(leafsetsmall, localinteger + interinteger)
                        if farestsha == -1 do
                              if neighbourinteger < localinteger && shatempneighbour > Enum.at(leafsetsmall, 0) do
                                {deletesha, leafsetsmall} = List.pop_at(leafsetsmall, 0)
                                leafsetsmall = leafsetsmall ++ [shatempneighbour]
                                leafsetsmall = Enum.sort(leafsetsmall)
                                leafsetmap = Map.delete(leafsetmap, deletesha)
                                leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                              end
                        else
                              if shatempneighbour > Enum.at(leafsetsmall, farestsha) || neighbourinteger < localinteger do
                                {deletesha, leafsetsmall} = List.pop_at(leafsetsmall, farestsha)
                                leafsetsmall = leafsetsmall ++ [shatempneighbour]
                                leafsetsmall = Enum.sort(leafsetsmall)
                                leafsetmap = Map.delete(leafsetmap, deletesha)
                                leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                              end 
                        end
                end
          end             
    else 
 #     IO.inspect "S2"
          if neighbourinteger > localinteger - interinteger && neighbourinteger < localinteger do
                if length(leafsetsmall) < @b/2 do
                  leafsetsmall = leafsetsmall ++ [shatempneighbour]
                  leafsetsmall = Enum.sort(leafsetsmall)
                  leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                else
                  if shatempneighbour > Enum.at(leafsetsmall, 0) do
                    {deletesha, leafsetsmall} = List.pop_at(leafsetsmall, 0)
                    leafsetsmall = leafsetsmall ++ [shatempneighbour]
                    leafsetsmall = Enum.sort(leafsetsmall)
                    leafsetmap = Map.delete(leafsetmap, deletesha)
                    leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                  end
                end
          else
                if length(leafsetbig) < @b/2 do
                  leafsetbig = leafsetbig ++ [shatempneighbour]
                  leafsetbig = Enum.sort(leafsetbig)
                  leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)
                else
                    farestsha = findfar2(leafsetbig, localinteger - interinteger)
                    if farestsha == -1 do
                          if Enum.at(leafsetbig, -1) > shatempneighbour && neighbourinteger > localinteger do
                            {deletesha, leafsetbig} = List.pop_at(leafsetbig, -1)
                            leafsetbig = leafsetbig ++ [shatempneighbour]
                            leafsetbig = Enum.sort(leafsetbig)
                            leafsetmap = Map.delete(leafsetmap, deletesha)
                            leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)              
                          end
                    else
                          if Enum.at(leafsetbig, farestsha) > shatempneighbour && neighbourinteger < localinteger do
                            {deletesha, leafsetbig} = List.pop_at(leafsetbig, farestsha)
                            leafsetbig = leafsetbig ++ [shatempneighbour]
                            leafsetbig = Enum.sort(leafsetbig)
                            leafsetmap = Map.delete(leafsetmap, deletesha)
                            leafsetmap = Map.put(leafsetmap, shatempneighbour, gpid)                 
                          end
                    end
                end
          end
    end
      leafsetbig = Enum.uniq(leafsetbig)
      leafsetsmall = Enum.uniq(leafsetsmall)
      rtnlist = %{:sha => [leafsetsmall, leafsetbig], :hashmap => leafsetmap}
      rtnlist
  end

  def findfar2(leafsetbig, lowbound) do
    rtn = findfar2loop(leafsetbig, lowbound, -1, 0)
    rtn
  end

  def findfar2loop([], lowbound, rtn, index) do
    rtn
  end
  
  def findfar2loop(leafsetbig, lowbound, rtn, index) do
    {temp, ""} = Integer.parse(hd(leafsetbig), 16)
    if temp < lowbound do
      rtn = index
    end
    rtn = findfar2loop(leafsetbig, lowbound, rtn, index + 1)
    rtn
  end

  def findfar(leafsetsmall, highbound) do
    rtn = findfarloop(leafsetsmall, highbound, -1, 0)
    rtn
  end

  def findfarloop([], highbound, rtn, index) do
    rtn
  end

  def findfarloop(leafsetsmall, highbound, rtn, index) do
    {temp, ""} = Integer.parse(hd(leafsetsmall), 16)
    if temp > highbound do
      rtn = index
    else 
      rtn = findfarloop(tl(leafsetsmall), highbound, rtn, index + 1)
    end
    rtn
  end

  def route(msg, shatemp, gpid, pid) do
    laststate = GenServer.call(pid, {:readstate})
#    IO.inspect laststate
    GenServer.cast(gpid, {:hear, msg, "route", shatemp, laststate})
#    GenServer.call(gpid, {:hear, msg, "route", shatemp, laststate})
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
end
