defmodule Execjs.Escape do
  @compile :native

  def escape(""),     do: ""
  def escape(string), do: escape(string, "")

  escape_map = [
    { ?\\, "\\\\" },
    { ?",  "\\\"" },
    { ?\n, "\\n"  },
    { ?\r, "\\r"  },
    # http://bclary.com/2004/11/07/#a-7.3
    { "\x{2028}", "\\u2028" },
    { "\x{2029}", "\\u2029" }
  ]

  for { char, escaped } <- escape_map do
    defp escape(<< unquote(char), rest :: binary >>, acc) do
      escape(rest, << acc :: binary, unquote(escaped) >>)
    end
  end

  defp escape(<< char :: utf8, rest :: binary >>, acc) do
    escape(rest, << acc :: binary, char :: utf8 >>)
  end

  defp escape(<<>>, acc) do
    acc
  end
end
