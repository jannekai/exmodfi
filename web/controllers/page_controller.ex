defmodule Exmodfi.PageController do
  use Exmodfi.Web, :controller

  require Logger

  plug :action

  @articles [
    [id: "elixir-meetup", date: "2015-03-26", title: "Presentation at Helsinki Elixir Meetup"],
    [id: "alkorytmi-by-cubicle", date: "2012-04-09", title: "Alkorytmi by Cubicle"],
    [id: "anglerfish-by-cubicle", date: "2011-08-08", title: "Anglerfish by Cubicle"],
    [id: "experiences-with-silex-php-framework", date: "2011-07-22", title: "Experiences with silex PHP framework"],
    [id: "nebel-4k-intro-by-cubicle", date: "2011-05-20", title: "Nebel a 4k intro by Cubicle"],
    [id: "sumu-4k-intro-by-cubicle", date: "2011-04-30", title: "Sumu a 4k intro by Cubicle"],
    [id: "google-wave", date: "2009-06-01", title: "Google Wave"],
    [id: "interface-does-make-a-difference", date: "2009-05-17", title: "Interface does make a difference"],
    [id: "site-updated-with-custom-cms", date: "2008-10-28", title: "Site updated with custom CMS"],
    [id: "assembly-2007", date: "2007-08-14", title: "Assembly 2007"],
    [id: "easy-backup-for-dynamic-web-sites", date: "2008-06-22", title: "Easy backup for dynamic web sites"],
    [id: "why-i-chose-wordpress", date: "2007-06-10", title: "Why I chose wordpress"]
  ]

  def index(conn, _params) do
    render conn, "index.html", pagetitle: "", articles: @articles
  end

  def show(conn, %{"page" => "contact"}) do
    render conn, "contact.html", pagetitle: " - Contact"
  end

  def show(conn, %{"article" => id}) do
    case find_article id do
      :error -> render conn, "page_not_found.html", pagetitle: "", article: id
      article -> render conn, "_article.html", pagetitle: " - #{article[:title]}", id: article[:id], date: article[:data], title: article[:title]
    end
  end

  def show(conn, _params) do
    render conn, "page_not_found.html", pagetitle: ""
  end

  defp find_article(article_id) do
    Enum.find(@articles, :error, fn(article) -> article[:id] == article_id end)
  end

end
