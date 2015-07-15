defmodule Exmodfi.PageView do
  use Exmodfi.Web, :view

  defp article_content(id) do
    Application.app_dir(:exmodfi, "priv/articles/#{id}.md") |> File.read! |> Earmark.to_html
  end

end
