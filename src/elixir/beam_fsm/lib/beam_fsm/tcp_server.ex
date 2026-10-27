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
    {:ok, %{listen_socket: listen_socket, nodes: %{}, topology_map: %{}}}
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
    handle_nodes(nodes, state.topology_map)
    IO.inspect(nodes, label: "Registered nodes")

    {:noreply, %{state | nodes: nodes}}
  end

  @impl true
  def handle_info(
        {:topology_map, <<"ST", payload_length::16-big, 6, topology_id::16-big, edges::binary>>},
        state
      ) do
    IO.puts("topology map from Orchestrator")
    IO.inspect(edges)
    map = create_topology_map(topology_id, edges, Map.new())
    handle_nodes(state.nodes, map)
    {:noreply, %{state | topology_map: map}}
  end

  def handle_nodes(nodes, topology_map) do
    Enum.each(topology_map, fn {from, to} ->
      case {Map.fetch(nodes, from), Map.fetch(nodes, to)} do
        {{:ok, source}, {:ok, destination}} -> send(source, {:peer, destination})
        _ -> :nothing
      end
    end)
  end

  defp create_topology_map(t_id, edges, map) do
    case edges do
      <<from::16-big, to::16-big>> ->
        new_map = Map.put_new(map, from, to)
        new_map

      <<from::16-big, to::16-big, other::binary>> ->
        new_map = Map.put_new(map, from, to)
        create_topology_map(t_id, other, new_map)
    end
  end
end
