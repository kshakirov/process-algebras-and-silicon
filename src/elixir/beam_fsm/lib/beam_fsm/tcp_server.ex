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
    spawn(fn -> accept_loop(listen_socket) end)
    {:ok, %{listen_socket: listen_socket, nodes: %{}}}
    #    {:ok, listen_socket}
  end

  defp accept_loop(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    handler = BeamFsm.TcpConnection.start()

    :ok = :gen_tcp.controlling_process(socket, handler)
    send(handler, {:socket, socket})

    accept_loop(listen_socket)
  end

  @impl true
  def handle_info({:register, node_id, pid}, state) do
    nodes = Map.put(state.nodes, node_id, pid)
    handle_nodes(nodes)
    IO.inspect(nodes, label: "Registered nodes")

    {:noreply, %{state | nodes: nodes}}
  end

  def handle_nodes(%{1 => k, 2 => v}) do
    send(k, {:peer, v})
  end

  def handle_nodes(_), do: :nothing
end
