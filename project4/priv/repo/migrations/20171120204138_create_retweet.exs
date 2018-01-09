defmodule Project4.Repo.Migrations.CreateRetweet do
  use Ecto.Migration

  def change do
    create table(:retweet) do
      add :retweetindex, :integer
      add :originindex, :integer
    end
  end
end
