defmodule KV.RouterTest do
  use ExUnit.Case

  setup_all do
    current = Application.get_env(:kv, :routing_table)

    Application.put_env(:kv, :routing_table, [
      {?a..?m, :"foo@vignesh-ThinkPad-E16-Gen-2"},
      {?n..?z, :"bar@vignesh-ThinkPad-E16-Gen-2:"}
    ])

    on_exit fn -> Application.put_env(:kv, :routing_table, current) end
  end

  @tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) ==
             :"foo@vignesh-ThinkPad-E16-Gen-2"
    assert KV.Router.route("world", Kernel, :node, []) ==
             :"bar@vignesh-ThinkPad-E16-Gen-2"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
