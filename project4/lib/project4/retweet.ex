defmodule Project4.Retweet do
    use Ecto.Schema
#    use Ecto.Model
    import Ecto.Query
    schema "retweet" do
      field :retweetindex, :integer
      field :originindex, :integer
    end
  end