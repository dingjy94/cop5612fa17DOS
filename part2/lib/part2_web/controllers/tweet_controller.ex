defmodule Part2Web.TweetController do
  @moduledoc false
  use Part2Web, :controller

  def tweet(conn, _params) do
    render conn, "tweet.html"
  end
end
