defmodule Exmodfi.PageControllerTest do
  use Exmodfi.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
