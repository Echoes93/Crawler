defmodule Crawler.Request.TokenizeTagsStage do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, [])
  end

  def init(state) do
    {:consumer, state}
  end

  def handle_events(tags, _from, state) do
    t = tags
    {:noreply, [], [t | state]}
  end

  def terminate(:normal, state) do
    IO.puts "terminated!!!"
    IO.inspect(state)
  end
end
