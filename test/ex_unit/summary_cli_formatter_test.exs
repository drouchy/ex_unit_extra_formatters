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
  test ":suite_started returns the config" do
    {:ok, default_config} = Formatter.handle_event({:suite_started, []}, default_config)
  end

  # event :suite_finished
  test ":suite_finished returns :remove_handler" do
    :remove_handler = Formatter.handle_event({:suite_finished, 0, 0}, default_config)
  end

  # event :test_started
  test ":test_started returns the config" do
    {:ok, default_config} = Formatter.handle_event({:test_started, nil}, default_config)
  end

  # event :case_started
  test ":case_started returns the config" do
    {:ok, default_config} = Formatter.handle_event({:case_started, nil}, default_config)
  end

  # event :case_finished
  test ":case_finished returns the config" do
    {:ok, default_config} = Formatter.handle_event({:case_finished, nil}, default_config)
  end

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
