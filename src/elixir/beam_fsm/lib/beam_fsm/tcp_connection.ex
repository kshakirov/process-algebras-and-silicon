defmodule BeamFsm.TcpConnection do
  def start do
    spawn(fn -> await_socket() end)
  end

  defp await_socket do
    receive do
      {:socket, socket} ->
        :ok = :inet.setopts(socket, active: :once)
        loop(socket, nil, <<>>)
    end
  end

  defp loop(socket, peer_id, buffer) do
    receive do
      {:tcp, ^socket, bytes} ->
        new_buffer = framer(socket, bytes, peer_id, buffer)
        :ok = :inet.setopts(socket, active: :once)
        loop(socket, peer_id, new_buffer)

      {:peer, pid} ->
        loop(socket, pid, buffer)

      {:data_from_prefix_generator, data} ->
        :gen_tcp.send(socket, data)
        loop(socket, peer_id, buffer)

      {:tcp_closed, ^socket} ->
        :ok

      {:tcp_error, ^socket, reason} ->
        IO.inspect(reason, label: "TCP error")
        :gen_tcp.close(socket)
    end
  end

  defp framer(socket, bytes, peer_id, buffer) do
    IO.inspect(buffer <> bytes)
    extract_frames(socket, peer_id, buffer <> bytes)
  end

  defp extract_frames(socket, peer_id, data) when byte_size(data) < 4 do
    data
  end

  # here I will check for payload
  defp extract_frames(socket, peer_id, data) when byte_size(data) >= 4 do
    handle_bytes(socket, data, peer_id)
    <<>>
  end

  # here i will fail the rest 
  defp extract_frames(socket, peer_id, data) when binary_part(data, 0, 2) != "ST" < 4 do
    handle_bytes(socket, data, peer_id)
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
