defmodule Crawler.Stage.AssembleTree do
  use GenStage

  def start_link(callback \\ &(&1)) do
    GenStage.start_link(__MODULE__, {[], callback})
  end

  def init(state) do
    {:consumer, state}
  end


  def handle_events(tags, _from, {state, callback}) do
    tokens = Enum.flat_map(tags, &:mochiweb_html.tokens(&1))
    {:noreply, [], {state ++ tokens, callback}}
  end

  def handle_cancel(_, _from, state) do
    {:stop, :normal, state}
  end

  def terminate(:normal, {state, callback}) do
    tree = :mochiweb_html.parse_tokens(state)
    callback.(tree)
  end
end
