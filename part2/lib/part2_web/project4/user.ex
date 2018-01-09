defmodule Project4.User do
    use Ecto.Schema
#    use Ecto.Model
    import Ecto.Query
    schema "user" do
      field :user_name, :string
      field :email, :string
      field :password, :string
    end
  end