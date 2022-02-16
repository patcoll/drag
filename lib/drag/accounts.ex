defmodule Drag.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Drag.Repo

  alias Drag.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |> order_by(asc: :position)
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc false
  def get_highest_position do
    User
    |> select([u], max_position: max(u.position))
    |> Repo.one()
    |> Keyword.get(:max_position)
  end

  @doc false
  def reorder_users(user_ids = [_ | _]) do
    user_ids =
      user_ids
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(fn
        :error -> 0
        {int, _} -> int
      end)

    all_users_map =
      User
      |> where([u], u.id in ^user_ids)
      |> Repo.all()
      |> Map.new(fn user -> {user.id, user} end)

    result =
      user_ids
      |> Enum.filter(&Enum.member?(Map.keys(all_users_map), &1))
      |> Enum.map(fn user_id ->
        new_position =
          user_ids
          |> Enum.find_index(&(&1 == user_id))
          |> reorder_users_index()

        {Map.get(all_users_map, user_id), new_position}
      end)
      |> Enum.flat_map(fn {user, new_position} ->
        [
          user
          |> User.changeset(%{})
          |> Ecto.Changeset.force_change(:position, new_position - 9999),
          user
          |> User.changeset(%{})
          |> Ecto.Changeset.force_change(:position, new_position)
        ]
      end)
      |> Enum.sort_by(&Ecto.Changeset.get_field(&1, :position))
      |> Enum.reduce(Ecto.Multi.new(), &reorder_users_multi/2)
      |> Repo.transaction()

    case result do
      {:ok, _} ->
        {:ok, list_users()}

      error ->
        error
    end
  end

  def reorder_users_index(zero_based_index) when is_integer(zero_based_index) do
    zero_based_index + 1
  end

  defp reorder_users_multi(changeset, multi) do
    update_id =
      "reorder_users__#{Ecto.Changeset.get_field(changeset, :id)}__#{Ecto.Changeset.get_field(changeset, :position)}"

    Ecto.Multi.update(
      multi,
      update_id,
      changeset
    )
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
