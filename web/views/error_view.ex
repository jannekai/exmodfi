defmodule Exmodfi.ErrorView do
  use Exmodfi.Web, :view

  require Logger

  def render("404.html", _assigns) do
    render "page_not_found.html"
  end

  def render("500.html", _assigns) do
    "Server internal error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, _assigns) do
    "Server internal error"
  end
end
