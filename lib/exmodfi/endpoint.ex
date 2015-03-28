defmodule Exmodfi.Endpoint do
  use Phoenix.Endpoint, otp_app: :exmodfi

  # Serve at "/" the given assets from "priv/static" directory
  plug Plug.Static,
    at: "/", from: :exmodfi,
    only: ~w(css images js data favicon.ico robots.txt)

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_exmodfi_key",
    signing_salt: "yd6BaO6D",
    encryption_salt: "cThOxGCH"

  plug :router, Exmodfi.Router
end
