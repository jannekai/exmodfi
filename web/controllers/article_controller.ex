defmodule Exmodfi.ArticleController do
  use Exmodfi.Web, :controller

  plug :action

  def show(conn, %{"article" => article}) do
    render conn, "article.html", article: article, title: article
  end
end
