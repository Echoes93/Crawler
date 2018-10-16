defmodule Crawler.Stage.ParseTags do
  use GenStage

  alias Crawler.Parser

  def start_link do
    GenStage.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:producer_consumer, ""}
  end


  def handle_events(html_chunks, _from, prev_remainer) do
    {tags_list, remainer} = Enum.reduce(html_chunks, {[], prev_remainer}, fn(chunk, {acc, remainer}) ->
      {tags_list, new_remainer} = Parser.parse_tags(remainer <> chunk)
      {[tags_list | acc], new_remainer}
    end)

    {:noreply, Enum.reverse(tags_list), remainer}
  end
end
