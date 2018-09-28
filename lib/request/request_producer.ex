defmodule Crawler.Request.Producer do
  use GenStage

  def start_link(url) do
    GenStage.start_link(__MODULE__, url)
  end

  def init(url) do
    {:ok, _status, _headers, body_ref} = :hackney.get(url, [], "", [follow_redirect: true])
    {:producer, body_ref}
  end


  def handle_cast(:end, state) do
    {:stop, :normal, state}
  end

  def handle_demand(demand, body_ref) when demand > 0 do
    chunks = Enum.reduce_while(0..demand, [], fn(_, acc) ->
      case :hackney.stream_body(body_ref) do
        {:ok, data} ->
          {:cont, acc ++ [data]}
        _ ->
          GenStage.cast(self(), :end)
          {:halt, acc}
      end
    end)

    {:noreply, chunks, body_ref}
  end
end
