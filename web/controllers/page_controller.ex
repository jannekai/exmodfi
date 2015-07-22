defmodule Exmodfi.PageController do
  use Exmodfi.Web, :controller

  @articles [
    [id: "deploying-phoenix-website-with-ansible", date: "2015-07-17", title: "Deploying a Phoenix website with Ansible"],
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
    render conn, "index.html", articles: @articles
  end

  def show(conn, %{"page" => "contact"}) do
    render conn, "contact.html"
  end

  def show(conn, %{"article" => id}) do
    case Enum.find @articles, fn article -> article[:id] == id end do
      nil -> page_not_found conn
      article -> render conn, "article.html", id: article[:id], date: article[:date], title: article[:title], comments: true
    end
  end

  def show(conn, _params) do
    page_not_found conn
  end

  defp page_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_layout(false)
    |> render(Exmodfi.ErrorView, "page_not_found.html")
  end

end
