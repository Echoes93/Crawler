defmodule StageTest do
  def test, do: run(100, 10, 5)

  def run(last, _max, _min) do
    {:ok, producer} = StageTest.Producer.start_link(last)
    {:ok, producer_consumer} = StageTest.ProducerConsumer.start_link()
    {:ok, consumer} = StageTest.Consumer.start_link()

    GenStage.sync_subscribe(consumer, to: producer_consumer, max_demand: 30, min_demand: 15)
    GenStage.sync_subscribe(producer_consumer, to: producer, max_demand: 15, min_demand: 7)
  end
end

defmodule StageTest.Producer do
  use GenStage

  def start_link(last), do: GenStage.start_link(__MODULE__, last)
  def init(last), do: {:producer, {0, last}}
  def handle_demand(_demand, :drained), do: {:stop, :normal, :drained}

  def handle_demand(demand, {start, last}) when demand > 0 do
    if start + demand < last do
      events = start..last |> Enum.take(demand)
      {:noreply, events, {start + demand, last}}
    else
      events = start..last |> Enum.take_every(1)
      {:noreply, events, :drained}
    end
  end
end

defmodule StageTest.ProducerConsumer do
  use GenStage

  def start_link, do: GenStage.start_link(__MODULE__, [])
  def init(_), do: {:producer_consumer, []}

  def handle_events(events, _from, state) do
    IO.puts "ProdCons items: #{length(events)}"
    {:noreply, events ++ events ++ events, state}
  end
end

defmodule StageTest.Consumer do
  use GenStage

  def start_link, do: GenStage.start_link(__MODULE__, [])
  def init(_), do: {:consumer, []}

  def handle_events(events, _from, state) do
    IO.puts "Cons items: #{length(events)}"
    {:noreply, [], state}
  end
end
