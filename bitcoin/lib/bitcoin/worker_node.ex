defmodule Bitcoin.WorkerNode do
  @moduledoc """
  the workers mine bitcoin
"""
  use GenServer
  @ufid "dingjy94"


  def handle_cast(args, numOfZero) when is_list(args) do
    min_val = Enum.at(args, 0)
    range = Enum.at(args, 1)
    master = Enum.at(args, 2)
    coin_mining(min_val, min_val + range, numOfZero, master)
    send(master, {:finish, self()})

    { :noreply, numOfZero }
  end

  defp generate_key(cur_val, str) do
    remain = rem(cur_val, 96)
    cur_val = div(cur_val, 96)
    key = <<remain + 32>> <> str
    if cur_val == 0, do: key,
                     else: generate_key(cur_val, key)

  end

  defp coin_mining(cur_val, max_val, numOfZero, _)
  when cur_val == max_val, do: {:noreply, numOfZero}

  defp coin_mining(cur_val, max_val, numOfZero, master) do
    key = @ufid<>generate_key(cur_val, "")
    value = Base.encode16(:crypto.hash(:sha256, key))
    if value |> to_charlist |> check(numOfZero) do
      send master, {{String.to_atom(key), value}, self()}
    end
  coin_mining(cur_val+1, max_val, numOfZero, master)

  end

  #check whether the hash value suit the 0s' requirement
  defp check(_, 0), do: :true
  defp check([], _), do: :false
  defp check(value, numOfZero) do
    [head | tail] = value
    if head != 48, do: :false,
    else: check(tail, numOfZero-1)
  end

end
