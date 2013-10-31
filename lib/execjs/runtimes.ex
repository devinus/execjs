defmodule Execjs.Runtimes do
  import Execjs.Runtime

  Module.register_attribute __MODULE__, :runtimes, accumulate: true

  defruntime JavaScriptCore,
    command: "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc",
    runner: "jsc_runner.js.eex"

  defruntime Node,
    command: "node",
    runner: "node_runner.js.eex"

  def runtimes, do: @runtimes

  def best_available do
    case :application.get_env(:execjs, :runtime) do
      { :ok, runtime } ->
        runtime
      :undefined ->
        runtime = Enum.find(@runtimes, &(&1.available?)) || raise RuntimeUnavailable
        :application.set_env(:execjs, :runtime, runtime)
        runtime
    end
  end
end
