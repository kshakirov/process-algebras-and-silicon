defmodule BeamFsm.Scheduler do
  def start_link(_options) do
    pid = spawn_link(fn -> loop() end)
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def child_spec(options) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [options]}
    }
  end

  defp loop do
    receive do
      message ->
        IO.inspect(message, label: "Scheduler получил")
        loop()
    end
  end
end
