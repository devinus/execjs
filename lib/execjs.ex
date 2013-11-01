defmodule Execjs do
  import Execjs.Escape, only: [escape: 1]

  defexception RuntimeError, message: nil

  defexception RuntimeUnavailable,
    message: "Could not find a JavaScript runtime"

  def compile(source) do
    { pre, post } = { "(function(){\n#{source};\n", ";\n})()" }
    fn (source) ->
      pre <> source <> post
    end
  end

  def call(context, thing, args) do
    source = "return #{thing}.apply(this, #{JSON.encode!(args)})"
    eval(context.(source))
  end

  def eval(source) do
    runtime = Execjs.Runtimes.best_available
    program = runtime.template(escape(source))
    command = runtime.command |> System.find_executable
    tmpfile = compile_to_tempfile(program)

    try do
      port = Port.open({ :spawn_executable, command },
        [:binary, :eof, :hide, { :args, [tmpfile] }])

      loop(port)
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
        port <- { self, :close }
        acc
    end
  end

  defp compile_to_tempfile(program) do
    hash = :erlang.phash2(:crypto.rand_bytes(8))
    filename = "execjs-#{hash}.js"
    path = Path.join(System.tmp_dir!, filename)
    File.write! path, program
    path
  end
end
