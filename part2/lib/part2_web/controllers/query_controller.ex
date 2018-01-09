defmodule Part2Web.QueryController do
  @moduledoc false

  use Part2Web, :controller

  def query(conn, _params) do
    render conn, "query.html"
  end
end
