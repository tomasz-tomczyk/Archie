import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :archie, ArchieWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :archie, Archie.Repo,
  database: "/data/archie.db",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Archie.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
