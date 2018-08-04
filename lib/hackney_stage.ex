defmodule HackneyStage do
  def get(url, fin_cb \\ &(&1), events_cb \\ &(&1)) do
    {:ok, producer} = HackneyStage.Producer.start_link(url)
    {:ok, consumer} = HackneyStage.Consumer.start_link(fin_cb, events_cb)

    GenStage.sync_subscribe(consumer, to: producer, max_demand: 10, min_demand: 5)
  end

  @test_url "https://en.wikipedia.org/wiki/Wikipedia"
  def test, do: HackneyStage.get(@test_url)
end

defmodule HackneyStage.Producer do
  use GenStage

  def start_link(url) do
    GenStage.start_link(__MODULE__, url)
  end

  def init(url) do
    {:ok, _status, _headers, body_ref} = :hackney.get(url, [], "", [follow_redirect: true])
    {:producer, body_ref}
  end

  def handle_cast(:consumed, state) do
    {:stop, :normal, state}
  end

  def handle_demand(demand, body_ref) when demand > 0 do
    chunks = Enum.reduce_while(0..demand, [], fn(_, acc) ->
      case :hackney.stream_body(body_ref) do
        {:ok, data} -> {:cont, acc ++ [data]}
        _ -> {:halt, [:drained, acc]}
      end
    end)

    {:noreply, chunks, body_ref}
  end
end


defmodule HackneyStage.Consumer do
  use GenStage

  def start_link(fin_cb, events_cb) do
    GenStage.start_link(__MODULE__, {fin_cb, events_cb})
  end

  def init(callbacks) do
    {:consumer, {:os.system_time(), "", callbacks}}
  end


  def handle_events([:drained, chunks], {pid, _ref}, {started, state, {fin_cb, _events_cb}}) do
    final_state = Enum.reduce(chunks, state, &(&2 <> &1))

    fin_cb.(final_state)
    IO.puts "Data Length: #{String.length(final_state)}"
    IO.puts "Time Passed: #{(:os.system_time() - started) / 1000}"

    GenStage.cast(pid, :consumed)

    {:stop, :normal, final_state}
  end

  def handle_events(chunks, _from, {started, state, {_fin_cb, events_cb} = callbacks}) do
    new_state = Enum.reduce(chunks, state, &(&2 <> &1))

    events_cb.(chunks)

    {:noreply, [], {started, new_state, callbacks}}
  end
end
