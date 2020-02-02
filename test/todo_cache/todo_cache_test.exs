defmodule TodoCacheTest do
  use ExUnit.Case

  test "creates a server process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "peforms to-do operations" do
    {:ok, cache} = Todo.Cache.start()

    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, ~D[2018-12-19], "Dentist")

    entries = Todo.Server.entries(alice, ~D[2018-12-19])

    assert ["Dentist"] = entries
  end
end
