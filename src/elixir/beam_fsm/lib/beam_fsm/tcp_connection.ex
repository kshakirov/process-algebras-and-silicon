defmodule BeamFsm.TcpConnection do
  def start do
    spawn(fn -> await_socket() end)
  end
  
  defp await_socket do
    receive do
      {:socket, socket} ->
        :ok = :inet.setopts(socket, active: :once)
        loop(socket)
    end
  end

  defp loop(socket) do
    receive do
      {:tcp, ^socket, bytes} ->
        handle_bytes(socket, bytes)

        :ok = :inet.setopts(socket, active: :once)
        loop(socket)

      {:tcp_closed, ^socket} ->
        :ok

      {:tcp_error, ^socket, reason} ->
        IO.inspect(reason, label: "TCP error")
        :gen_tcp.close(socket)
    end
  end

  defp handle_bytes(socket, _bytes) do
   registered =
  <<"ST", 1::16-big, 2>>

  :gen_tcp.send(
    socket,
    registered

  )
  end

  # defp handle_bytes(socket, _bytes) do
  #   :gen_tcp.send(socket, "ERROR UNKNOWN_REQUEST")
  # end
end
