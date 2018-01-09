defmodule Project4.Repo.Migrations.CreateFollow do
  use Ecto.Migration

  def change do
    create table(:follow) do
      add :email, :string
      add :follow, :string
    end
  end
end
