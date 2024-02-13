# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :backend_fight,
  ecto_repos: [BackendFight.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :backend_fight, BackendFight.Mailer, adapter: Swoosh.Adapters.Local

config :backend_fight_web,
  ecto_repos: [BackendFight.Repo],
  generators: [context_app: :backend_fight]

# Configures the endpoint
config :backend_fight_web, BackendFightWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BackendFightWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BackendFight.PubSub,
  live_view: [signing_salt: "P01t/RGH"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
