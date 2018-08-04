defmodule Crawler.Request do
  alias Crawler.Request

  def get(url, fin_cb \\ &(&1), events_cb \\ &(&1)) do
    {:ok, producer} = Request.Producer.start_link(url)
    {:ok, consumer} = Request.Consumer.start_link(fin_cb, events_cb)

    GenStage.sync_subscribe(consumer, to: producer, max_demand: 10, min_demand: 5)
  end


  def test do
    pid = self()
    started_at = :os.system_time()

    Request.get("https://en.wikipedia.org/wiki/Wikipedia", &send(pid, {:finished, &1}))

    receive do
      {:finished, state} ->
        IO.puts "Data Length: #{String.length(state)}"
        IO.puts "Time Passed: #{(:os.system_time() - started_at) / 1000}"
    end
  end
end
