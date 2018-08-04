defmodule GunServer do
  use GenServer

  def test do
    started = :os.system_time()

    {:ok, conn_pid} = :gun.open('en.wikipedia.org', 443)
    stream_ref = :gun.get(conn_pid, '/wiki/Wikipedia')
    {:ok, data} = :gun.await_body(conn_pid, stream_ref)

    IO.puts "Data Length: #{String.length(data)}"
    IO.puts "Time Passed: #{(:os.system_time() - started) / 1000}"
  end


  def start(host, url \\ '/', port \\ 443) do
    GenServer.start_link(__MODULE__, {host, url, port})
  end

  def init({host, url, port}) do
    {:ok, conn_pid} = :gun.open(host, port)
    stream_ref = :gun.get(conn_pid, url)

    {:ok, {conn_pid, stream_ref}}
  end

  def handle_info({:gun_response, _conn, _stream, _is_fin, _status, _headers}, state) do
    {:noreply, state}
  end

  def handle_info({:gun_data, _conn, _stream, _is_fin, _data}, state) do
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
