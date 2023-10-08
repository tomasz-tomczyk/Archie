defmodule Archie.Repo do
  use Ecto.Repo,
    otp_app: :archie,
    adapter: Ecto.Adapters.SQLite3
end
