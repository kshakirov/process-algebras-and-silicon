defmodule BeamFsm.Application do
  @moduledoc false

  use Application

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      BeamFsm.Scheduler
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: BeamFsm.Supervisor
    )
  end
end
