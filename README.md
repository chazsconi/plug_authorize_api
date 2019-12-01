# Plug.AuthorizeAPI

Use to authorise API requests using an API key in the request header.

## Installation

```elixir
def deps do
  [
    {:plug_authorize_api, "~> 0.1.0"}
  ]
end

```

## Usage

At the top of your router add:

```elixir
import AlacantWeb.Plug.AuthorizeAPI, only: [authorize_api: 2]
```

...add a pipe:
```elixir
pipeline :api do
  plug(:accepts, ["json"])
  plug(:authorize_api)
end
```

...then around the routes you want to protect add:

```elixir
pipe_through(:authorized_api)
```

In your `config.exs` you must put a list of permitted routes per client, and a
map of api-keys to clients.
```elixir
config :plug_authorize_api,
  permitted_routes: [my_client: [{:post, "/foo/bar"}, {:get, "/foo/bar/*"}]],
  api_keys: %{"my-client-api-key" => :my_client}
```
