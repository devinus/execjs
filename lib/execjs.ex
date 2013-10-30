defmodule Execjs do
  defexception RuntimeUnavailable, message: nil

  def eval(string) do
    runtime = Execjs.Runtimes.best_available
    program = runtime.template(escape(string))
    command = runtime.command |> System.find_executable

    port = Port.open({ :spawn_executable, command },
      [:binary, :eof, :hide, { :args, ["-e", program] }])

    loop(port)
  end

  defp loop(port) do
    loop(port, "")
  end

  defp loop(port, acc) do
    receive do
      { ^port, { :data, data } } ->
        loop(port, acc <> data)
      { ^port, :eof } ->
        port <- { self, :close }
        JSON.decode!(acc)
    end
  end

  defp escape(string) do
    iolist_to_binary(escape(string, ""))
  end

  escape_map = [
    { ?\\, "\\\\" },
    { ?",  "\\\"" },
    { ?\n, "\\n"  },
    { ?\r, "\\r"  },
    { "\x{2028}", "\\u2028" },
    { "\x{2029}", "\\u2029" }
  ]

  lc { char, escaped } inlist escape_map do
    defp escape(<< unquote(char), rest :: binary >>, acc) do
      escape(rest, [acc, unquote(escaped)])
    end
  end

  defp escape(<< char :: utf8, rest :: binary >>, acc) do
    escape(rest, [acc, char])
  end

  defp escape(<<>>, acc) do
    acc
  end
end

defexception Execjs.RuntimeError, message: nil

defexception Execjs.RuntimeUnavailable,
  message: "Could not find a JavaScript runtime"

defmodule Execjs.Runtime do
  app = Mix.project[:app]

  def runner_path(runner) do
    Path.join([:code.priv_dir(unquote(app)), runner])
  end

  defmacro defruntime(name, options) do
    quote do
      defmodule unquote(name) do
        require EEx

        def command, do: unquote(options[:command])

        def available?, do: !!System.find_executable(command)

        runner_path = Execjs.Runtime.runner_path(unquote(options[:runner]))
        EEx.function_from_file :def, :template, runner_path, [:source]
      end

      @runtimes unquote(name)
    end
  end
end

defmodule Execjs.Runtimes do
  import Execjs.Runtime

  Module.register_attribute __MODULE__, :runtimes, accumulate: true

  defruntime JavaScriptCore,
    command: "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc",
    runner: "jsc_runner.js.eex"

  def runtimes, do: @runtimes

  def best_available do
    unless runtime = Process.get(:execjs_best_runtime) do
      runtime = Enum.find(@runtimes, &(&1.available?)) || raise RuntimeUnavailable
      Process.put(:execjs_best_runtime, runtime)
    end
    runtime
  end
end
