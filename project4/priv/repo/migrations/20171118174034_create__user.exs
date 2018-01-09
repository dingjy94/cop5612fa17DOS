defmodule Project4.Repo.Migrations.Create_User do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :user_name, :string
      add :email, :string
      add :password, :string
    end
  end
end
