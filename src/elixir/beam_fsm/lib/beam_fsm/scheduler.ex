
defmodule BeamFsm.Scheduler do
  use GenServer

  def start_link(initial, opts \\ []) do
    GenServer.start_link(__MODULE__, initial, opts)
  end

  @impl true
  def init(initial), do: {:ok, initial}

  def get_status(pid), do: GenServer.call(pid, :get_status)
  def update_status(pid, counts), do: GenServer.call(pid, {:update_status, counts})
  def increment_status(pid), do: GenServer.call(pid, :increment_status)

  def submit_task(pid, task), do: GenServer.call(pid, {:submit_task, task})  

  def add_fact(pid, fact), do: GenServer.call(pid, {:add_fact, fact})  
  

  
  @impl true
  def handle_call({:update_status, counts}, _from, state) do
    new_state = %{state |  counter:  state.counter + counts}
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:increment_status, _from, state) do
    new_state = %{state |  counter:  state.counter + 1}
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:get_status, _from, state) do
    {:reply, state.counter, state.counter}
  end

  @impl true
  def handle_call({:submit_task, task}, _from, state) do
    new_state = %{state |  task:  task}
    IO.puts(task.(2))
    {:reply,task.(2), new_state}
  end

  @impl true
  def handle_call({:add_fact, fact}, _from, state) do
    new_state = %{state |  fact:  fact}

    {:reply,new_state, new_state}
  end

end
