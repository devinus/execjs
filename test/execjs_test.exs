defmodule ExecjsTest do
  use ExUnit.Case

  import Execjs

  alias Execjs.RuntimeError

  test "eval" do
    assert eval(~s(var a = "a"; a + "b")) == "ab"
    assert eval(~s(\x{2028}\nvar str = "foo";\x{2029}\n))

    assert_raise RuntimeError, fn ->
      eval("xxx")
    end
  end

  test "call" do
    context = compile ~S"""
    function addOne(n) {
      return n + 1;
    }
    """

    assert call(context, "addOne", [3]) == 4
    assert call(context, "addOne", [-3]) == -2
  end
end
