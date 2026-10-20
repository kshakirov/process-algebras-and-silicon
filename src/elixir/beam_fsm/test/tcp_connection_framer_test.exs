defmodule BeamFsm.TcpConnectionFramerTest do
  use ExUnit.Case, async: false

  @register <<"ST", 5::16-big, 1, 1::16-big, 3::16-big>>
  @registered <<"ST", 1::16-big, 2>>

  setup do
    # Receive registration messages without starting the application or Prolog client.
    Process.register(self(), BeamFsm.TcpServer)

    options = [:binary, packet: :raw, active: false, ip: {127, 0, 0, 1}]
    {:ok, listener} = :gen_tcp.listen(0, options)
    {:ok, {_, port}} = :inet.sockname(listener)
    {:ok, client} = :gen_tcp.connect({127, 0, 0, 1}, port, options)
    {:ok, socket} = :gen_tcp.accept(listener)
    :ok = :gen_tcp.close(listener)

    handler = BeamFsm.TcpConnection.start()
    :ok = :gen_tcp.controlling_process(socket, handler)
    send(handler, {:socket, socket})

    on_exit(fn ->
      :gen_tcp.close(client)
      if Process.alive?(handler), do: Process.exit(handler, :kill)
    end)

    {:ok, client: client, socket: socket, handler: handler}
  end

  test "keeps an incomplete payload until the remaining bytes arrive", context do
    <<first::binary-size(6), rest::binary>> = @register
    send(context.handler, {:tcp, context.socket, first})

    assert {:error, :timeout} = :gen_tcp.recv(context.client, 0, 100)
    refute_receive {:register, _, _}, 0

    send(context.handler, {:tcp, context.socket, rest})

    assert {:ok, @registered} = :gen_tcp.recv(context.client, byte_size(@registered), 1_000)
    assert_receive {:register, 3, handler} when handler == context.handler
  end

  test "processes both frames from one TCP delivery", context do
    send(context.handler, {:tcp, context.socket, @register <> @register})

    expected = @registered <> @registered
    assert {:ok, ^expected} = :gen_tcp.recv(context.client, byte_size(expected), 1_000)
    assert_receive {:register, 3, handler} when handler == context.handler
    assert_receive {:register, 3, handler} when handler == context.handler
  end
end
