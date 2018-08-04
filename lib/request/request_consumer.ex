defmodule Crawler.Request.Consumer do
  use GenStage

  def start_link(fin_cb, events_cb) do
    GenStage.start_link(__MODULE__, {fin_cb, events_cb})
  end

  def init(callbacks) do
    {:consumer, {"", callbacks}}
  end


  def handle_events([:drained, chunks], {pid, _ref}, {state, {fin_cb, _events_cb}}) do
    final_state = Enum.reduce(chunks, state, &(&2 <> &1))

    fin_cb.(final_state)
    GenStage.cast(pid, :consumed)

    {:stop, :normal, final_state}
  end

  def handle_events(chunks, _from, {state, {_fin_cb, events_cb} = callbacks}) do
    new_state = Enum.reduce(chunks, state, &(&2 <> &1))

    events_cb.(chunks)

    {:noreply, [], {new_state, callbacks}}
  end
end
