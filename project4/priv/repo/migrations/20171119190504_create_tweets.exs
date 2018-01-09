defmodule Project4.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweet) do
      add :email, :string
      add :tweet, :string
      add :hashtag, :string
      add :mention, :string

      timestamps()
    end
  end
end
