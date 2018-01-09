defmodule Part2Web.PageController do
  use Part2Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
