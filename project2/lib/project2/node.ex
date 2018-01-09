defmodule Project2.Node do
  @moduledoc """
  node in network
"""
  use GenServer

  def handle_cast(args, initialS) when is_list(args) do
    initialW = 1
    main = Enum.at(args, 0)
    neighbors = Enum.at(args, 1)
    running(neighbors, initialS, initialW, initialS/initialW, 0, 0, main)
    
    { :noreply, initialS }
  end


  defp running(neighbors, currentS, currentW, currentRatio, currentrounds, terminate, master) do
    receive do
      {[s, w], pid} ->
          newS = currentS + s
          newW = currentW + w
          newRatio = newS/newW
          newrounds = currentrounds
          newterminate = terminate
          if abs(newRatio - currentRatio) > :math.pow(10, -10) do
            newS = newS/2
            newW = newW/2
            newrounds = 0
            receiver = Enum.random(neighbors)
            send receiver, {[newS, newW], self()}

          else
            newrounds = newrounds + 1
            if newrounds < 3 do
              newS = newS/2
              newW = newW/2
              receiver = Enum.random(neighbors)
              send receiver, {[newS, newW], self()}

            else
              newterminate =
                if terminate == 0 do
                  send master, {:finish, self()}
                  1
                else
                  terminate
                end
              newS = newS/2
              newW = newW/2
              receiver = Enum.random(neighbors)
              send receiver, {[newS, newW], self()}

            end
          end

        running(neighbors, newS, newW, newRatio, newrounds, newterminate, master)
      {:start, pid} ->
        newS = currentS/2
        newW = currentW/2
        newRatio = newS/newW
        newrounds = 0
        receiver = Enum.random(neighbors)
        send receiver, {[newS, newW], self()}
        other = List.delete(neighbors, receiver)
        if length(other) != 0 do
          another = Enum.random(other)
          send another, {[newS, newW], self()}
        end
        send master, {:started, self()}
        running(neighbors, newS, newW, newRatio, newrounds, terminate, master)
    end
  end


end
