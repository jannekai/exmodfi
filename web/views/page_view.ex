defmodule Exmodfi.PageView do
  use Exmodfi.Web, :view

  defp article_content(id) do
    "priv/articles/#{id}.md" |> File.read!  |> Earmark.to_html
  end

end
