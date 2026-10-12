defmodule BeamFsm.TcpConnection do
  def start do
    spawn(fn -> await_socket() end)
  end

  defp await_socket do
    receive do
      {:socket, socket} ->
        :ok = :inet.setopts(socket, active: :once)
        loop(socket, nil)
    end
  end

  defp loop(socket, peer_id) do
    receive do
      {:tcp, ^socket, bytes} ->
        handle_bytes(socket, bytes, peer_id)

        :ok = :inet.setopts(socket, active: :once)
        loop(socket, peer_id)

      {:peer, pid} ->
        loop(socket, pid)

      {:data_from_prefix_generator, data} ->
        :gen_tcp.send(socket, data)
        loop(socket, peer_id)

      {:tcp_closed, ^socket} ->
        :ok

      {:tcp_error, ^socket, reason} ->
        IO.inspect(reason, label: "TCP error")
        :gen_tcp.close(socket)
    end
  end

  defp handle_bytes(
         socket,
         <<"ST", 5::16-big, 1, topology_id::16-big, node_id::16-big>>,
         _peer_id
       ) do
    IO.inspect(topology_id)
    IO.inspect(node_id)

    registered = <<"ST", 1::16-big, 2>>
    :gen_tcp.send(socket, registered)

    send(BeamFsm.TcpServer, {:register, node_id, self()})
  end

  defp handle_bytes(_socket, <<"ST", len::16-big, 3, data>>, peer_id) do
    IO.inspect(len)
    IO.inspect(data)
    send(peer_id, {:data_from_prefix_generator, data})

    :ok
  end

  defp handle_bytes(socket, _bytes, _peer_id) do
    :gen_tcp.send(socket, "ERROR UNKNOWN_REQUEST")
  end
end
