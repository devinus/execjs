defmodule ExecjsTest do
  use ExUnit.Case

  test "eval" do
    assert Execjs.eval("1 + 1") == 2
    assert Execjs.eval(%s{var a = "a"; a + "b"}) == "ab"
  end

  test "call" do
    context = Execjs.compile(%S""")
    function addOne(n) {
      return n + 1;
    }
    """

    assert Execjs.call(context, "addOne", [3]) == 4
  end
end
