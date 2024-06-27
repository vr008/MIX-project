defmodule KVServerTest do
  use ExUnit.Case
  @moduletag :capture_log

  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN team\r\n") ==
           "UNKNOWN COMMAND\r\n"

    assert send_and_recv(socket, "GET team strikers \r\n") ==
           "NOT FOUND\r\n"

    assert send_and_recv(socket, "POST team\r\n") ==
           "OK\r\n"

    assert send_and_recv(socket, "PUT team strikers [634,3308]\r\n") ==
           "OK\r\n"

    # GET returns two lines
    assert send_and_recv(socket, "GET team strikers\r\n") == "[634,3308]\r\n"
    assert send_and_recv(socket, "") == :timeout

    assert send_and_recv(socket, "DELETE team strikers\r\n") ==
           "OK\r\n"

    # GET returns two lines
    assert send_and_recv(socket, "GET team strikers\r\n") == "\r\n"
    assert send_and_recv(socket, "") == :timeout
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    case :gen_tcp.recv(socket, 0,1000) do
      {:ok,data} -> data
      {:error,:timeout} -> :timeout
    end
  end


end
