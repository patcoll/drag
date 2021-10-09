defmodule Drag.Repo do
  use Ecto.Repo,
    otp_app: :drag,
    adapter: Ecto.Adapters.Postgres
end
