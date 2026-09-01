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

  @doc "Asynchronous dispatch"
  def update_status do
    GenServer.cast(__MODULE__, {:update_status})
  end

  @impl true
  def handle_cast(:update_status, _status) do
    {:noreply, 1}
  end

  @impl true
  def handle_call(:get_status, _from, state) do
    {:reply, 1, state}
  end

  # # def start_link(_options) do
  # #   pid = spawn_link(fn -> loop() end)
  # #   Process.register(pid, __MODULE__)
  # #   {:ok, pid}
  # # end

  # # def child_spec(options) do
  # #   %{
  # #     id: __MODULE__,
  # #     start: {__MODULE__, :start_link, [options]}
  # #   }
  # # end

  # defp loop do
  #   receive do
  #     message ->
  #       IO.inspect(message, label: "Scheduler получил")
  #       loop()
  #   end
  # end
end
