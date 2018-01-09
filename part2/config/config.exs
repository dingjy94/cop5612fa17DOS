# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :part2,
  ecto_repos: [Part2.Repo]

# Configures the endpoint
config :part2, Part2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bweaG25TLa1Fmmtu6G5StOCVHSKu8SpXAjRqLKTlyC7Fcc/R9/UIcjW32WI+HC2X",
  render_errors: [view: Part2Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Part2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
