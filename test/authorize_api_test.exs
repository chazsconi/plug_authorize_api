defmodule AlacantWeb.Plug.AuthorizeAPITest do
  use ExUnit.Case
  use Plug.Test
  import Plug.AuthorizeAPI, only: [authorize_api: 2]
  import ExUnit.CaptureLog

  test "authorized with api key and valid route" do
    conn =
      :post
      |> conn("/foo/bar", "")
      |> put_api_key()
      |> authorize_api([])

    assert conn.state == :unset
  end

  test "authorized with api key and valid route and query params" do
    conn =
      :post
      |> conn("/foo/bar?x=1", "")
      |> put_api_key()
      |> authorize_api([])

    assert conn.state == :unset
  end

  test "authorized with api key and wildcard route" do
    conn =
      :get
      |> conn("/foo/bar/123", "")
      |> put_api_key()
      |> authorize_api([])

    assert conn.state == :unset
  end

  test "unauthorized with no api key" do
    capture_log(fn ->
      conn =
        :post
        |> conn("/foo/bar", "")
        |> authorize_api([])

      assert conn.state == :sent
      assert conn.status == 401
    end)
  end

  test "unauthorized with unknown api key" do
    capture_log(fn ->
      conn =
        :post
        |> conn("/foo/bar", "")
        |> put_api_key("bad-api-key")
        |> authorize_api([])

      assert conn.state == :sent
      assert conn.status == 401
    end)
  end

  test "forbidden with non permitted route" do
    capture_log(fn ->
      conn =
        :post
        |> conn("/bad/route", "")
        |> put_api_key()
        |> authorize_api([])

      assert conn.state == :sent
      assert conn.status == 403
    end)
  end

  test "forbidden with non permitted wildcard route" do
    capture_log(fn ->
      conn =
        :get
        |> conn("/bad/route", "")
        |> put_api_key()
        |> authorize_api([])

      assert conn.state == :sent
      assert conn.status == 403
    end)
  end

  defp put_api_key(conn, key \\ "plug-test-api-key") do
    put_req_header(conn, "api-key", key)
  end
end
