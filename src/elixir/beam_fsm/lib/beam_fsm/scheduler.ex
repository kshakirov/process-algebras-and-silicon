
defmodule BeamFsm.Scheduler do
  use GenServer
  alias BeamFsm.Scheduler.Core


  def start_link(initial, opts \\ []) do
    GenServer.start_link(__MODULE__, initial, opts)
  end

  @impl true
  def init(initial), do: {:ok, initial}

  def submit_task(pid, task), do: GenServer.call(pid, {:submit_task, task})  

  def add_fact(pid, fact), do: GenServer.call(pid, {:add_fact, fact})  
  

  
  
  @impl true
  def handle_call({:submit_task, task}, _from, state) do
    new_state = %{state |   tasks: [ task | state.tasks] }
    IO.puts("Submitting Predicate and Testing it with number 2 =  #{task.(2)}")
    {:reply,true, new_state}
  end

  @impl true
  def handle_call({:add_fact, fact}, _from, state) do
    new_state = %{state |  facts:  [fact | state.facts]}

    result = state.task.(fact.value)
    IO.puts("Fact added: a predicate run on it, result is  #{result}")
    Core.run_predicates_on_facts(state.facts, state.tasks)
    {:reply,result, new_state}
  end

end
