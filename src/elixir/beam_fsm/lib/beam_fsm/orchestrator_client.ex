defmodule BeamFsm.OrchestratorClient do
  use GenServer
  @host {127, 0, 0, 1}
  @port 9400
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    state = %{
      host: @host,
      port: @port,
      socket: nil,
      status: :connecting
    }

    {:ok, state, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    options = [:binary, packet: :raw, active: false]

    case :gen_tcp.connect(state.host, state.port, options) do
      {:ok, socket} ->
        new_state = %{
          state
          | socket: socket,
            status: :connected
        }

        {:noreply, new_state}

      {:error, reason} ->
        {:stop, reason, state}
    end
  end
end
