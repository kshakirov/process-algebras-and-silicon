defmodule BeamFsm.Scheduler do
  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  @impl true
  def init(initial) do
    {:ok, initial}
  end

  @doc "Synchronous dispatch"
  def get_status do
    GenServer.call(__MODULE__, :get_status)
  end


  @doc "Synchronous dispatch"
  def update_status(counts) do
    GenServer.call(__MODULE__, {:update_status, counts})
  end


  @doc "Synchronous dispatch"
  def increment_status do
    GenServer.call(__MODULE__, :increment_status)
  end

  # @doc "Asynchronous dispatch"
  # def update_status do
  #   GenServer.cast(__MODULE__, {:update_status})
  # end

  @impl true
  def handle_call({:update_status, counts} , _from, state) do
    new_state = state + counts
    {:reply, new_state ,  new_state}
  end


  @impl true
  def handle_call(:increment_status, _from, state) do
    new_state = state + 1
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:get_status, _from, state) do
    {:reply, state, state}
  end


end
