defmodule Project2.GossipNode do
  @moduledoc false

  use GenServer

  def handle_cast(args, initialS) when is_list(args) do
    main = Enum.at(args, 0)
    neighbors = Enum.at(args, 1)
    running(neighbors, main, 0, 0)

    { :noreply, initialS }
  end


  def running(neighbors, main, count, reported) do
    receive do
      {:roumor, pid} ->
        if count < 10 do
          count = count + 1
        end
        newreported =
          if reported == 0 and count == 10 do
            send main, {:finish, self()}
            1
          else
            reported
          end
        :timer.sleep(1)
        receiver = Enum.random(neighbors)
        send receiver, {:roumor, self()}

        running(neighbors, main, count, newreported)
      {:start, pid} ->
        count = count + 1
        receiver = Enum.random(neighbors)
        send main, {:started, self()}
        send receiver, {:roumor, self()}
        other = List.delete(neighbors, receiver)
        if length(other) != 0 do
          another = Enum.random(other)
          send another, {:roumor, self()}
        end
        running(neighbors, main, count, reported)
    end
  end
end
