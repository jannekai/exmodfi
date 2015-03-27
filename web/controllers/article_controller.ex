defmodule Exmodfi.ArticleController do
  use Exmodfi.Web, :controller

  plug :action

  def article(conn, %{"article" => article}) do
    render conn, "article.html", article: article
  end
end
