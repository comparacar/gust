defmodule Gust.CLI do
  @moduledoc """
  Command-line entrypoint for operational Gust tasks.

  This module is invoked by the release wrapper script and dispatches supported
  CLI commands into the application runtime.

  ## Supported commands

  * `trigger_run <dag_name>`: starts the application, looks up the DAG by name,
    creates a run for it, and dispatches that run through the configured
    `Gust.DAG.Run.Trigger` implementation.

  Example:

      gust-cli trigger_run my_dag
  """

  alias Gust.DAG.Run.Trigger
  alias Gust.Flows
  require Logger

  @doc """
  Executes a supported CLI command.

  Currently supported commands:

  * `["trigger_run", dag_name]`
  """
  def exec(["trigger_run", dag_name]) do
    load_app()

    dag = Flows.get_dag_by_name(dag_name)
    {:ok, run} = Flows.create_run(%{dag_id: dag.id})
    run = Trigger.dispatch_run(run)

    Logger.warning("Triggered DAG #{dag.name}; Run: #{run.id}")
  end

  defp load_app do
    Application.ensure_all_started(:gust)
  end
end
