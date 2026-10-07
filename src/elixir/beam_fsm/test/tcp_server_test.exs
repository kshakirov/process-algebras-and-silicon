defmodule BeamFsm.TcpServerTest do
  use ExUnit.Case, async: false

  @host {127, 0, 0, 1}
  @port 9300
  @socket_options [:binary, packet: :raw, active: false]

  test "returns the hardcoded prefix generator address" do
    {:ok, socket} = :gen_tcp.connect(@host, @port, @socket_options)
    register =
  <<"ST", 5::16-big, 1, 1::16-big, 3::16-big>>
  registered =
  <<"ST", 1::16-big, 2>>
    :ok = :gen_tcp.send(socket, register)
    response = :gen_tcp.recv(socket,0,1_1000)
    IO.inspect(response)
    assert {:ok, registered} == response
    :ok =
      :gen_tcp.send(socket, register)

    assert {:ok, registered} ==
      :gen_tcp.recv(socket, 0, 1_000)
  end

  test "rejects an unknown request" do
    {:ok, socket} = :gen_tcp.connect(@host, @port, @socket_options)

    :ok = :gen_tcp.send(socket, "UNKNOWN_REQUEST")

#    assert receive_until_closed(socket) == "ERROR UNKNOWN_REQUEST"
  end


end
