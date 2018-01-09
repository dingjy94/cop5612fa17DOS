defmodule Bitcoin do
  @moduledoc """
  Documentation for Bitcoin.
  """

  @doc """
  main function

  """
  def main(arg) do
    [args] = arg
    list = String.split(args, ".")
    ip = getip()
    cond do
      length(list) == 1 ->
        IO.puts "One machine."
        Enum.at(list, 0) |> String.to_integer |> Bitcoin.ServerNode.start_server(ip)
      length(list) == 4 ->
        IO.puts "remote machine"
        Bitcoin.RemoteNode.start_remoteWorker(ip, args)
      :true -> IO.puts "ong output #{inspect length(list)}"
    end
  end

  defp getip() do
    { :ok, [ { {a,b,c,d} , _, _ }, _ ] } = :inet.getif()
    to_string(a) <> <<?.>> <>
    to_string(b) <> <<?.>> <>
    to_string(c) <> <<?.>> <>
    to_string(d)
  end

end
