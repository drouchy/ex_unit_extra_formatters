defmodule ExUnit.SummaryCLIFormatterWithColorsTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExUnit.SummaryCLIFormatter, as: Formatter

  # init
  test "inits with colors" do
    {:ok, %{colors: [enabled: true]}} = Formatter.init([colors: [enabled: true]])
  end

  # event :suite_started
  test "retuns :ok" do
    {:ok, default_config} = Formatter.handle_event({:suite_started, []}, default_config)
  end

  # event :suite_finished

  # event :test_started

  # event :test_finished
  test "writes a green dot for a success" do
    output = capture_io fn ->
      Formatter.handle_event({:test_finished, %ExUnit.Test{state: nil}}, default_config)
    end

    assert output == "\e[32m.\e[0m"
  end

  test "writes an yellow star for a skip" do
    output = capture_io fn ->
      Formatter.handle_event({:test_finished, %ExUnit.Test{state: {:skip, nil}}}, default_config)
    end

    assert output == "\e[33m*\e[0m"
  end

  test "writes a red F for a failure" do
    output = capture_io fn ->
      Formatter.handle_event({:test_finished, %ExUnit.Test{state: {:failed, nil}}}, default_config)
    end

    assert output == "\e[31mF\e[0m"
  end

  defp default_config, do: %{failures: [], colors: [enabled: true]}
end
