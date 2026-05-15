defmodule GustWeb.API do
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

  When `gust_api/0` is declared, Gust checks whether `GUST_API_TOKEN` exists
  in the environment and emits a compile-time warning if it is missing.

  Set `:gust_web, :api_enabled` to mount the built-in `/api` routes:

      config :gust_web, api_enabled: true
  """

  defmacro gust_api do
    warn_on_missing_api_token_env(__CALLER__)

    quote do
      post("/dags/:dag_name/run", GustWeb.APIController, :create_run)
    end
  end

  defp warn_on_missing_api_token_env(env) do
    if System.fetch_env("GUST_API_TOKEN") == :error do
      IO.warn(
        "Gust API route was declared, but GUST_API_TOKEN environment variable is not configured. " <>
          "Gust API requests will be unauthorized.",
        Macro.Env.stacktrace(env)
      )
    end
  end
end
