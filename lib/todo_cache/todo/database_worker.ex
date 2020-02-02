defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    IO.puts("Starting database worker.")

    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.cast(pid, {:get, key})
  end

  def init(db_folder) do
    {:ok, {nil, db_folder}}
  end

  def handle_cast({:store, key, data}, {_, folder} = state) do
    key
    |> file_name(folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({:store, key}, {_, folder} = state) do
    data =
      case File.read(file_name(key, folder)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
