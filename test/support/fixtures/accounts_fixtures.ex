defmodule Drag.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Drag.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name",
        position: 42
      })
      |> Drag.Accounts.create_user()

    user
  end
end
