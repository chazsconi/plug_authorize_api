defmodule Plug.AuthorizeAPI do
  @moduledoc """
  Plug to verify the API key is authorised
  """
  require Logger

  def authorize_api(conn, _opts) do
    with [api_key] <- Plug.Conn.get_req_header(conn, "api-key"),
         {:ok, client} <- get_client_by_api_key(api_key),
         {:ok, permitted_routes} <- get_permitted_routes(client),
         :ok <- check_permitted_route(conn, permitted_routes) do
      Logger.info("authorize_api success client: #{client}")

      conn
      |> Plug.Conn.assign(:api_client, client)
    else
      result ->
        {status, message} =
          case result do
            [] ->
              {:unauthorized, "No api-key header provided"}

            {:error, :unauthorized} ->
              {:unauthorized, "Unknown api-key client"}

            {:error, :forbidden} ->
              {:forbidden, "Non permitted route for api-key"}
          end

        Logger.warn("authorize_api - #{message}")

        conn
        |> Plug.Conn.send_resp(status, message)
        |> Plug.Conn.halt()
    end
  end

  defp get_client_by_api_key(api_key) do
    case Map.fetch(config(:api_keys), api_key) do
      {:ok, client} -> {:ok, client}
      :error -> {:error, :unauthorized}
    end
  end

  defp get_permitted_routes(client) do
    case config(:permitted_routes)[client] do
      nil -> {:error, :unauthorized}
      routes -> {:ok, routes}
    end
  end

  defp check_permitted_route(
         %Plug.Conn{method: method, request_path: req_path},
         permitted_routes
       ) do
    req_method = method |> String.downcase() |> String.to_atom()

    match? =
      permitted_routes
      |> Enum.any?(fn {method, path} ->
        req_method == method and path_matches?(req_path, path)
      end)

    if match? do
      :ok
    else
      {:error, :forbidden}
    end
  end

  defp path_matches?(req_path, match_path)

  defp path_matches?(req_path, match_path) when req_path == match_path, do: true

  defp path_matches?(req_path, match_path) do
    if String.ends_with?(match_path, "*") do
      String.starts_with?(req_path, String.trim_trailing(match_path, "*"))
    else
      false
    end
  end

  defp config(key), do: Application.get_env(:plug_authorize_api, key)
end
