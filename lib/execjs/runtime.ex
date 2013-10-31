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
