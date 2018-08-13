defmodule Execjs.Runtime do
  @moduledoc "Defines the `defruntime/2` macro to define JavaScript runtimes."

  alias Mix.Project

  app = Project.config()[:app]

  def runner_path(runner) do
    Path.join([:code.priv_dir(unquote(app)), runner])
  end

  defmacro defruntime(runtime, options) do
    name = Macro.to_string(runtime)

    quote do
      defmodule unquote(runtime) do
        @moduledoc "Runtime definition for #{unquote(name)}."

        require EEx

        alias Execjs.Runtime

        def executables, do: unquote(options[:executables])

        def command, do: Enum.find(executables(), &System.find_executable(&1))

        def arguments, do: unquote(options[:arguments] || [])

        def available?, do: not (command() == nil)

        @runner_path Runtime.runner_path(unquote(options[:runner]))
        @external_resource @runner_path

        EEx.function_from_file(:def, :template, @runner_path, [:source])
      end

      @runtimes unquote(runtime)
    end
  end
end
