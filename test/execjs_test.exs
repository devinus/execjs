defmodule ExecjsTest do
  use ExUnit.Case

  test "eval" do
    # assert Execjs.eval("(function() { return 1 + 1; })();") == ["ok", 2]

    IO.inspect Execjs.eval(%S""")
(function() {
function addOne(n) {
  return n + 1;
}

return addOne(3);
})();
"""
  end
end
