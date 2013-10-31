defexception Execjs.RuntimeError, message: nil

defexception Execjs.RuntimeUnavailable,
  message: "Could not find a JavaScript runtime"

defmodule Execjs do
  def eval(string) do
    runtime = Execjs.Runtimes.best_available
    program = runtime.template(escape(string))
    command = runtime.command |> System.find_executable
    tmpfile = compile(program)

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

  defp compile(program) do
    hash = :erlang.phash2(:crypto.rand_bytes(8))
    filename = "execjs-#{hash}.js"
    path = Path.join(System.tmp_dir!, filename)
    File.write! path, program
    path
  end

  def escape(string) do
    iolist_to_binary(escape(string, ""))
  end

  escape_map = [
    { ?\\, "\\\\" },
    { ?",  "\\\"" },
    { ?\n, "\\n"  },
    { ?\r, "\\r"  },
    # http://bclary.com/2004/11/07/#a-7.3
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
