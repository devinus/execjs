defmodule ExecjsTest do
  use ExUnit.Case

  test "eval" do
    # assert Execjs.eval("(function() { return 1 + 1; })();") == ["ok", 2]

    context = Execjs.compile(%S""")
function addOne(n) {
  return n + 1;
}
"""

    IO.inspect Execjs.call(context, "addOne", [3])
  end
end
