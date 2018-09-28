defmodule Crawler.Request.TokenizeTagsStage do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, [])
  end

  def init(state) do
    {:consumer, state}
  end

  def handle_events(tags, _from, state) do
    {:noreply, [], state ++ tags }
  end

  def terminate(:normal, state) do
    IO.puts "terminated!!!"
    File.write!('./tags.txt', state)
    IO.puts("done")
  end
end
