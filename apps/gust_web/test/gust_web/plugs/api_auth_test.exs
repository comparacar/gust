defmodule GustWeb.Plugs.APIAuthTest do
  use GustWeb.ConnCase, async: true

  alias GustWeb.Plugs.APIAuth

  @token "gust-test-token"

  setup do
    previous_token = Application.get_env(:gust_web, :api_token)
    Application.put_env(:gust_web, :api_token, @token)

    on_exit(fn ->
      if previous_token do
        Application.put_env(:gust_web, :api_token, previous_token)
      else
        Application.delete_env(:gust_web, :api_token)
      end
    end)

    :ok
  end

  test "allows requests with the configured bearer token", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{@token}")
      |> APIAuth.call([])

    refute conn.halted
  end

  test "allows bearer scheme with different casing", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "bearer #{@token}")
      |> APIAuth.call([])

    refute conn.halted
  end

  test "halts requests without authorization", %{conn: conn} do
    conn = APIAuth.call(conn, [])

    assert conn.halted
    assert json_response(conn, 401) == %{"error" => "unauthorized"}
  end

  test "halts requests with an invalid bearer token", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer invalid-token")
      |> APIAuth.call([])

    assert conn.halted
    assert json_response(conn, 401) == %{"error" => "unauthorized"}
  end

  test "halts requests when no API token is configured", %{conn: conn} do
    Application.delete_env(:gust_web, :api_token)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{@token}")
      |> APIAuth.call([])

    assert conn.halted
    assert json_response(conn, 401) == %{"error" => "unauthorized"}
  end
end
