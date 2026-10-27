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
      status: :connecting,
      data: <<>>
    }

    {:ok, state, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    options = [:binary, packet: :raw, active: false]

    case :gen_tcp.connect(state.host, state.port, options) do
      {:ok, socket} ->
        :ok = :inet.setopts(socket, active: :once)

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

  @impl true
  def handle_info({:tcp, socket, bytes}, state) do
    IO.inspect(bytes, label: "Received from Prolog")
    data = handle_prolog_response(socket, state.data <> bytes)

    :ok = :inet.setopts(socket, active: :once)

    {:noreply, state}
  end

  @impl true
  def handle_info({:createTopology, bytes}, state) do
    IO.inspect(bytes, label: "Received from Tcp Connection")
    :gen_tcp.send(state.socket, bytes)
    IO.puts("All data sent to Prolog")
    {:noreply, state}
  end

  defp handle_prolog_response(socket, <<"ST", payload_length::16-big, data::binary>>)
       when byte_size(data) < payload_length do
    IO.puts("My handler is not yet  working, not enough bytes ")
    <<"ST", payload_length::16-big, data::binary>>
  end

  defp handle_prolog_response(socket, <<"ST", payload_length::16-big, 6, data::binary>>)
       when byte_size(data) == payload_length - 1 do
    IO.puts("My handler is working ")
    <<"ST", payload_length::16-big, 6, data::binary>>
  end
end
