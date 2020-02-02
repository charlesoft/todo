defmodule Todo.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @spec init(any) :: {:ok, {%{intensity: any, period: any, strategy: any}, [any]}}
  def init(_) do
    Supervisor.init([Todo.Cache], strategy: :one_for_one)
  end
end
