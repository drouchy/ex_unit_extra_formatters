defmodule ExUnit.SummaryCLIFormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExUnit.SummaryCLIFormatter, as: Formatter

  # init
  test "returns the config" do
    {:ok, _config} = Formatter.init([])
  end

  test "inits a failure accumulator" do
    {:ok, %{failures: []}} = Formatter.init([colors: []])
  end

  test "inits with no color by default" do
    {:ok, %{colors: []}} = Formatter.init([])
  end

  # event :suite_started

  # event :suite_finished

  # event :test_started

  # event :test_finished
  test "writes a dot for a success" do
    output = capture_io fn ->
      Formatter.handle_event({:test_finished, %ExUnit.Test{state: nil}}, default_config)
    end

    assert output == "."
  end

  test "does not change the config for a success" do
    capture_io fn ->
      {:ok, new_config} = Formatter.handle_event({:test_finished, %ExUnit.Test{state: nil}}, default_config)

      assert new_config == default_config
    end
  end

  test "writes a star for a skip" do
    output = capture_io fn ->
      Formatter.handle_event({:test_finished, %ExUnit.Test{state: {:skip, nil}}}, default_config)
    end

    assert output == "*"
  end

  test "does not change the config for a skip" do
    capture_io fn ->
      {:ok, new_config} = Formatter.handle_event({:test_finished, %ExUnit.Test{state: {:skip, nil}}}, default_config)
      assert new_config == default_config
    end
  end

  test "writes a F for a failure" do
    output = capture_io fn ->
      Formatter.handle_event({:test_finished, %ExUnit.Test{state: {:failed, nil}}}, default_config)
    end

    assert output == "F"
  end

  test "captures the failing test" do
    capture_io fn ->
      test = %ExUnit.Test{state: {:failed, 'FAILURE'}}
      {:ok, new_config} = Formatter.handle_event({:test_finished, test}, %{failures: ['previous test']})
      assert new_config[:failures] == ['previous test', test]
    end
  end

  defp default_config, do: %{failures: [], colors: []}
end
