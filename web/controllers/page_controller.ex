defmodule Exmodfi.PageController do
  use Exmodfi.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html", title: ""
  end
end
