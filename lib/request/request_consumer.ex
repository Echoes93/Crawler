defmodule Crawler.Request.Consumer do
  use GenStage

  def start_link(fin_cb, events_cb) do
    GenStage.start_link(__MODULE__, {fin_cb, events_cb})
  end

  def init(callbacks) do
    {:consumer, {"", callbacks}}
  end


  def handle_events(chunks, _from, {state, {_fin_cb, events_cb} = callbacks}) do
    new_state = Enum.reduce(chunks, state, &(&2 <> &1))

    events_cb.(chunks)

    {:noreply, [], {new_state, callbacks}}
  end

  def terminate(:normal, {state, {fin_cb, _events_cb}}) do
    IO.puts "terminated!!!"
    fin_cb.(state)
  end
end
