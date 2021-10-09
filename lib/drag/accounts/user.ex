defmodule Drag.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Drag.Accounts

  schema "users" do
    field :name, :string
    field :position, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
    |> add_position()
  end

  defp add_position(changeset) do
    case get_change(changeset, :position) do
      nil ->
        next_position = case Accounts.get_highest_position() do
          nil -> 1
          highest_position -> highest_position + 1
        end

        put_change(changeset, :position, next_position)

      _position ->
        changeset
    end
  end
end
