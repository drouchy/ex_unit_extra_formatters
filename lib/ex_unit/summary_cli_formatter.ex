defmodule ExUnit.SummaryCLIFormatter do
  @moduledoc false

  use GenEvent

  import ExUnit.Formatter, only: [format_time: 2, format_filters: 2, format_test_failure: 5,
                                  format_test_case_failure: 5]

  def init(opts) do
    config = %{
      colors: opts[:colors] || [],
      failures: []
    }
    # IO.inspect config
    {:ok , config}
  end

  def handle_event({:suite_started, opts}, config) do
    {:ok, config}
  end

  def handle_event({:suite_finished, _run_us, _load_us}, _config) do
    :remove_handler
  end

  def handle_event({:case_started, _test_case}, config) do
    {:ok, config}
  end

  def handle_event({:case_finished, _test_case}, config) do
    {:ok, config}
  end

  def handle_event({:test_finished, %ExUnit.Test{state: nil} = test}, config) do
    write_success(".", config)
    {:ok, config}
  end

  def handle_event({:test_started, _test}, config) do
    # if config.trace, do: IO.write "  * #{trace_test_name test}"
    {:ok, config}
  end

  def handle_event({:test_finished, %ExUnit.Test{state: {:skip, _}} = test}, config) do
    write_warning("*", config)
    {:ok, config}
  end

  def handle_event({:test_finished, %ExUnit.Test{state: {:failed, failed}} = test}, config) do
    write_error("F", config)
    new_config = Map.put(config, :failures, config[:failures] ++ [test])
    {:ok, new_config}
  end

  defp write_success(message, %{colors: [enabled: true]}), do: write_with_color(:green, message)
  defp write_success(message, _),                          do: write_no_color(message)

  defp write_warning(message, %{colors: [enabled: true]}),  do: write_with_color(:yellow, message)
  defp write_warning(message, _),                           do: write_no_color(message)

  defp write_error(message, %{colors: [enabled: true]}),  do: write_with_color(:red, message)
  defp write_error(message, _),                           do: write_no_color(message)

  defp write_no_color(message),   do: IO.write(message)
  defp write_with_color(color, message) do
    [
      IO.ANSI.format_fragment([color]),
      message,
      IO.ANSI.format_fragment([:reset])
    ]
      |> IO.iodata_to_binary
      |> IO.write
  end
end
