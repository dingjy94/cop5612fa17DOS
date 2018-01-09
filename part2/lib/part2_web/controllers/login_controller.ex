defmodule Part2Web.LoginController do
  @moduledoc false
  use Part2Web, :controller

  def login(conn, _params) do
    render conn, "login.html"
  end
end
