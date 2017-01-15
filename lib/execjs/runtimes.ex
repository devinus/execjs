defmodule Execjs.Runtimes do
  import Execjs.Runtime

  alias Execjs.RuntimeUnavailable

  Module.register_attribute __MODULE__, :runtimes, accumulate: true

  defruntime Node,
    command: "node",
    runner: "node_runner.js.eex"

  defruntime SpiderMonkey,
    command: "js",
    runner: "spidermonkey_runner.js.eex"

  defruntime JavaScriptCore,
    command: "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc",
    runner: "jsc_runner.js.eex"

  defruntime Rhino,
    command: "rhino",
    runner: "rhino_runner.js.eex"

  def runtimes do
    unquote(Enum.reverse(@runtimes))
  end

  def best_available do
    case :application.get_env(:execjs, :runtime) do
      { :ok, runtime } ->
        runtime
      :undefined ->
        runtime = case System.get_env("EXECJS_RUNTIME") do
          nil ->
            Enum.find(runtimes(), &(&1.available?)) || raise RuntimeUnavailable
          name ->
            runtime = Module.concat(__MODULE__, name)
            Code.ensure_loaded?(runtime)
              && function_exported?(runtime, :available?, 0)
              && runtime.available?
              || raise RuntimeUnavailable
            runtime
        end
        :application.set_env(:execjs, :runtime, runtime)
        runtime
    end
  end
end
