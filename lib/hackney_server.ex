defmodule HackneyServer do
  use GenServer

  def test do
    started = :os.system_time()
    {:ok, _status, _headers, body_ref} = :hackney.get("https://en.wikipedia.org/wiki/Wikipedia")
    {:ok, data} = :hackney.body(body_ref)

    IO.puts "Data Length: #{String.length(data)}"
    IO.puts "Time Passed: #{(:os.system_time() - started) / 1000}"

    :ok
  end

  def start(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def next(pid) do
    GenServer.call(pid, :next)
  end

  # Callbacks
  def init(url) do
    {:ok, _status, _headers, body_ref} = :hackney.get(url, [], "", [follow_redirect: true])

    {:ok, body_ref}
  end

  def handle_call(:next, _from, body_ref) do
    case :hackney.stream_body(body_ref) do
      {:ok, chunk} -> {:reply, {:chunk, chunk}, body_ref}
      :done -> {:stop, :normal, :done, body_ref}
    end
  end
end
