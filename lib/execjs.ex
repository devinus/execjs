defmodule Execjs do
  import Execjs.Escape, only: [escape: 1]

  defmodule Error, do: defexception [:message]
  defmodule RuntimeError, do: defexception [:message]

  defmodule RuntimeUnavailable do
    defexception message: "Could not find JavaScript runtime"
  end

  @spec eval(String.t) :: any
  def eval(source) when is_binary(source) do
    exec ~s[eval("#{escape(source)}")]
  end

  @spec compile(String.t) :: (String.t -> String.t)
  def compile(source) when is_binary(source) do
    { pre, post } = { "(function(){\n#{source};\n", ";\n})()" }
    fn (source) ->
      pre <> source <> post
    end
  end

  @spec call((String.t -> String.t), String.t, list(any)) :: any
  def call(context, identifier, args) when is_binary(identifier) and is_list(args) do
    source = "return #{identifier}.apply(this, #{Poison.encode!(args, escape: :javascript)})"
    exec context.(source)
  end

  defp exec(source) do
    runtime = Execjs.Runtimes.best_available
    program = runtime.template(source)
    command = runtime.command |> System.find_executable
    tmpfile = compile_to_tempfile(program)

    try do
      port = Port.open({ :spawn_executable, command },
        [:stream, :in, :binary, :eof, :hide, { :args, [tmpfile] }])

      extract_result(loop(port))
    after
      File.rm! tmpfile
    end
  end

  defp loop(port) do
    loop(port, "")
  end

  defp loop(port, acc) do
    receive do
      { ^port, { :data, data } } ->
        loop(port, acc <> data)
      { ^port, :eof } ->
        send port, { self(), :close }
        receive do: ({ ^port, :closed } -> :ok)
        acc
    end
  end

  defp compile_to_tempfile(program) do
    hash = :erlang.phash2(:crypto.strong_rand_bytes(8))
    filename = "execjs-#{hash}.js"
    path = Path.join(System.tmp_dir!, filename)
    File.write! path, program
    path
  end

  defp extract_result(output) do
    case Poison.decode!(output) do
      [ "ok", value ] ->
        value
      [ "ok" ] ->
        :undefined
      [ "err", message ] ->
        raise %RuntimeError{message: message}
      [ "err" ] ->
        raise %Error{message: "Unknown error"}
    end
  end
end
