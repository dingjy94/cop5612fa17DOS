defmodule Part2Web.ConnectChannel do
  @moduledoc false
  use Phoenix.Channel
  use GenServer
  require Logger

  def join("twitter:connect", _params, socket) do
    Logger.info("somebody connect")
    {:ok, socket}
  end

  def handle_in("signin", %{"user" => user, "password" => password}, socket) do
    up = [user, nil, password, [], []]
    Logger.info("up is")
    tweets = GenServer.call(:global.whereis_name(:usertable), {:login, up})
    IO.inspect "got tweets"
    IO.inspect tweets
    if !is_nil(tweets) do

      {:reply, {:ok, %{kind: "private", from: "server", body: tweets}}, socket}
    else
      {:reply, {:ok, %{kind: "private", from: "server", body: "error"}}, socket}
    end
  end

  def handle_in("subscribe", %{"email" => email, "self" => self}, socket) do
    GenServer.call(:global.whereis_name(:usertable), {:update_subscribe, self, email})
    #folloewed list updated
    GenServer.call(:global.whereis_name(:usertable), {:update_followed, email, self})
    {:reply, {:ok, %{kind: "private", from: "server", body: "subscribed successfully"}}, socket}
  end

  def handle_in("tweet", %{"email" => email, "tweet" => tweet}, socket) do
    tweet = tweet
    hashtag = nil
    mention = nil
    retweet = nil

    tweettemp = [email, tweet, hashtag, mention, retweet]

    tweettablepid = :global.whereis_name(:tweettable)

    rtntweet = GenServer.call(tweettablepid, {:tweet, tweettemp})
    Logger.info("tweet")
    {:reply, {:ok, %{kind: "private", from: "server", body: "send tweet successfully, please refresh"}}, socket}
  end

  def handle_in("retweet", %{"email" => email, "tweet" => tweet}, socket) do
    [emailt, tweetcontentt, mentiont, hashtagt, retweett, timestampt, hashindext] = tweet
    tweet = [email, tweetcontentt, mentiont, hashtagt, retweett, timestampt, hashindext]
    rtntweet = GenServer.call(:global.whereis_name(:tweettable), {:retweet, tweet})
    {:reply, {:ok, %{kind: "private", from: "server", body: "send tweet successfully, please refresh"}}, socket}

  end

  def handle_in("query", %{"argument" => argument, "method" => method}, socket) do
    rtnquery = GenServer.call(:global.whereis_name(:tweettable), {:query, method, argument})
    rtnlength = length(rtnquery)
    IO.inspect rtnquery
    IO.inspect Integer.to_string(rtnlength) <> " tweets found in total " <> Integer.to_string(GenServer.call(:global.whereis_name(:tweetnumber), :readstate)) <> " tweets"

    Logger.info("query")
    {:reply, {:ok, %{kind: "private", from: "server", body: rtnquery}}, socket}
  end
end
