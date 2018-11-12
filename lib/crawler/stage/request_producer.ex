defmodule Crawler.Stage.Producer do
  use GenStage

  def start_link(uri, source_mod \\ Crawler.HTTPSource) do
    GenStage.start_link(__MODULE__, {uri, source_mod})
  end

  def init({uri, source_mod}) do
    case source_mod.open(uri) do
      {:ok, ref} ->
        {:producer, {ref, source_mod}}
      {:error, reason} ->
        {:stop, reason}
    end
  end


  def handle_demand(demand, {ref, source_mod}) when demand > 0 do
    chunks = Enum.reduce_while(0..demand, [], fn(_, acc) ->
      case source_mod.next(ref) do
        {:ok, data} ->
          {:cont, acc ++ [data]}
        _ ->
          GenStage.cast(self(), :end)
          {:halt, acc}
      end
    end)

    {:noreply, chunks, {ref, source_mod}}
  end


  def handle_cast(:end, state), do: {:stop, :normal, state}
  def terminate(_reason, {ref, source_mod}), do: source_mod.close(ref)
end
