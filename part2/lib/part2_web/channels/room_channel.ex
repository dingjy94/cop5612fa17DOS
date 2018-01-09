defmodule Part2Web.RoomChannel do
  use Phoenix.Channel
  use GenServer
  require Logger

  def join("twitter:signup", _message, socket) do
    Logger.info("somebody sign up")
   # GenServer.call(:global.whereis_name(:usertable), {:register, user})
    {:ok, socket}
  end

  def handle_in("signup", %{"user" => user, "password" => password, "email" => email}, socket) do
    upe = [user, password, email, [], []]
    Logger.info("upe is")
    Logger.info(upe)
    GenServer.call(:global.whereis_name(:usertable), {:register, upe})
    {:reply, {:ok, %{kind: "private", from: "server", body: "user registered"}}, socket}
  end

end
