defmodule Megasena.Repo do
  use Ecto.Repo,
    otp_app: :megasena,
    adapter: Ecto.Adapters.Postgres
end
