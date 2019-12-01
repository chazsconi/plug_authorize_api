use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

config :plug_authorize_api,
  permitted_routes: [test_client: [{:post, "/foo/bar"}, {:get, "/foo/bar/*"}]],
  api_keys: %{"plug-test-api-key" => :test_client}
