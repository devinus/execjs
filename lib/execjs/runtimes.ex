defmodule Execjs.Runtimes do
  @moduledoc """
  Registers supported runtimes and exposes the `best_available/0` function to
  find the most optimal runtime on the current system.
  """

  import Execjs.Runtime

  defmodule UnavailableError do
    defexception message: "Could not find suitable JavaScript runtime"
  end

  Module.register_attribute(__MODULE__, :runtimes, accumulate: true)

  defruntime(Node,
    runner: "node_runner.js.eex",
    executables: ~w[node nodejs],
    arguments: ["--no-deprecation"]
  )

  defruntime(V8,
    runner: "v8_runner.js.eex",
    executables: ~w[v8 d8],
    arguments: []
  )

  defruntime(SpiderMonkey,
    runner: "spidermonkey_runner.js.eex",
    executables: ~w[js52 js24 js],
    arguments: []
  )

  defruntime(JavaScriptCore,
    runner: "jsc_runner.js.eex",
    executables: ~w[
    jsc
    /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc
    ],
    arguments: ["-s"]
  )

  defruntime(Rhino,
    runner: "rhino_runner.js.eex",
    executables: ["rhino"],
    arguments: ["-debug"]
  )

  def runtimes do
    unquote(Enum.reverse(@runtimes))
  end

  def best_available do
    case Application.get_env(:execjs, :runtime) do
      nil ->
        runtime = guess_runtime()
        Application.put_env(:execjs, :runtime, runtime)
        runtime

      runtime ->
        runtime
    end
  end

  defp guess_runtime do
    case System.get_env("EXECJS_RUNTIME") do
      nil ->
        Enum.find(runtimes(), & &1.available?) || raise UnavailableError

      name ->
        runtime = Module.concat(__MODULE__, name)

        if not (Code.ensure_loaded?(runtime) &&
                  function_exported?(runtime, :available?, 0) &&
                  runtime.available?) do
          raise UnavailableError
        end

        runtime
    end
  end
end
