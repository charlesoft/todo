defmodule Todo.Server do
  use GenServer

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name)
  end

  def add_entry(pid, worker_key, key, value) do
    GenServer.cast(pid, {:put, worker_key, key, value})
  end

  def entries(pid, worker_key, key) do
    GenServer.call(pid, {:get, worker_key, key})
  end

  @impl GenServer
  def init(list_name) do
    {:ok, {list_name, Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:put, worker_key, key, value}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, key, value)

    Todo.Database.store(worker_key, list_name, new_list)

    {:noreply, {list_name, todo_list}}
  end

  @impl GenServer
  def handle_call({:get, worker_key, key}, _, {list_name, _todo_list} = state) do
    todo_list = Todo.Database.get(worker_key, list_name)

    {:reply, Todo.List.entries(todo_list, key), state}
  end
end
