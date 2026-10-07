defmodule BeamFsm.TcpServer do
  use GenServer

  @port 9300

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    options = [
      :binary,
      packet: :raw,
      active: false,
      reuseaddr: true
    ]

    {:ok, listen_socket} = :gen_tcp.listen(@port, options)

    {:ok, listen_socket, {:continue, :accept}}
  end

  @impl true
  def handle_continue(:accept, listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)


    handler = BeamFsm.TcpConnection.start()

    :ok =
      :gen_tcp.controlling_process(socket, handler)

    send(handler, {:socket, socket})

    {:noreply, listen_socket, {:continue, :accept}}
  end


end
