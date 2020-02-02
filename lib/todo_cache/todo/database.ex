defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start_link do
    IO.puts("Starting database server.")

    {:ok, worker0} = Todo.DatabaseWorker.start_link(@db_folder)
    {:ok, worker1} = Todo.DatabaseWorker.start_link(@db_folder)
    {:ok, worker2} = Todo.DatabaseWorker.start_link(@db_folder)

    workers = %{0 => worker0, 1 => worker1, 2 => worker2}

    GenServer.start_link(__MODULE__, workers, name: __MODULE__)
  end

  @spec store(any, any, any) :: :ok
  def store(worker_key, key, data) do
    GenServer.cast(__MODULE__, {:store, worker_key, key, data})
  end

  def get(worker_key, key) do
    GenServer.call(__MODULE__, {:get, worker_key, key})
  end

  def init(workers) do
    File.mkdir_p!(@db_folder)

    {:ok, workers}
  end

  def handle_cast({:store, worker_key, key, data}, workers) do
    pid = choose_worker(worker_key, workers)

    spawn(fn -> Todo.DatabaseWorker.store(pid, key, data) end)

    {:noreply, workers}
  end

  def handle_call({:get, worker_key, key}, caller, workers) do
    spawn(fn ->
      data =
        worker_key
        |> choose_worker(workers)
        |> Todo.DatabaseWorker.get(key)

      GenServer.reply(caller, data)
    end)

    {:noreply, workers}
  end

  defp choose_worker(key, workers), do: Map.get(key, workers)
end
