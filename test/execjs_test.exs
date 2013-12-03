defmodule ExecjsTest do
  use ExUnit.Case

  test "eval" do
    assert Execjs.eval(%s{var a = "a"; a + "b"}) == "ab"
    assert Execjs.eval(%s{\x{2028}\nvar str = "foo";\x{2029}\n})
  end

  test "call" do
    context = Execjs.compile(%S""")
    function addOne(n) {
      return n + 1;
    }
    """

    assert Execjs.call(context, "addOne", [3]) == 4
    assert Execjs.call(context, "addOne", [-3]) == -2
  end
end
