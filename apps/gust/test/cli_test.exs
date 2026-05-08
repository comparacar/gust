defmodule Gust.CLITest do
  use Gust.DataCase
  import ExUnit.CaptureLog

  import Gust.FlowsFixtures
  import Mox

  alias Gust.CLI
  alias Gust.Flows

  setup :verify_on_exit!
  setup :set_mox_from_context

  test "exec/1 triggers a run for a named dag" do
    dag_name = "cli_test_dag"
    dag = dag_fixture(%{name: "cli_test_dag"})
    dag_id = dag.id

    Gust.DAGRunTriggerMock
    |> expect(:dispatch_run, fn %Flows.Run{dag_id: ^dag_id} = run ->
      run
    end)

    {:ok, log} =
      with_log(fn ->
        CLI.exec(["trigger_run", dag_name])
      end)

    [last_run] = Flows.get_dag_with_runs!(dag_id).runs

    assert log =~ "Triggered DAG cli_test_dag; Run: #{last_run.id}"
  end
end
