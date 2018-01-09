defmodule Project4.Tweet do
    use Ecto.Schema
#    use Ecto.Model
    import Ecto.Query
    schema "tweet" do
      field :email, :string
      field :tweet, :string
      field :hashtag, :string
      field :mention, :string

      timestamps()
    end
  end