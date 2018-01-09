defmodule Part2Web.SubscribeController do
  @moduledoc false

  use Part2Web, :controller

  def sub(conn, _params) do
    render conn, "subscribe.html"
  end
end
