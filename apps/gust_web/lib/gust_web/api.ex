defmodule GustWeb.API do
  require Logger

  @moduledoc """
  Router macro that mounts Gust API routes inside a host scope.

  Import this module into your Phoenix router and call `gust_api/0` inside an
  API scope. The host router owns the prefix, so the API can be mounted wherever
  the host application needs it:

      import GustWeb.API

      scope "/gust/api" do
        pipe_through [:api]

        gust_api()
      end

  Set `:gust_web, :api_enabled` to mount the built-in `/api` routes and enable
  the boot-time token warning:

      config :gust_web, api_enabled: true
  """

  defmacro gust_api do
    quote do
      post("/dags/:dag_name/run", GustWeb.APIController, :create_run)
    end
  end

  @doc """
  Logs a warning when the Gust API token is not configured at runtime.

  This is called during `GustWeb.Application` boot when
  `:gust_web, :api_enabled` is true. It can also be called by host applications
  that mount `gust_api/0` themselves.
  """
  def warn_on_missing_config do
    token = Application.get_env(:gust_web, :api_token)

    if is_binary(token) and token != "" do
      :ok
    else
      Logger.warning(
        "Gust API token is not configured. " <>
          "Set :gust_web, :api_token or define GUST_API_TOKEN to authorize API requests."
      )

      {:error, :missing_api_token}
    end
  end
end
