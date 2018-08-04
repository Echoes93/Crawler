defmodule PoisonRequest do

  def get(url) do
    response = HTTPoison.get!(url, [], [stream_to: self(), async: :once])

    receive do
      %HTTPoison.AsyncStatus{} -> process(response)
      msg -> IO.inspect(msg)
    end
  end

  defp process(response) do
    HTTPoison.stream_next(response)

    receive do
      %HTTPoison.AsyncHeaders{} ->
        IO.puts "HEADERS"
        process(response)
      %HTTPoison.AsyncChunk{} ->
        IO.puts "CHUNK"
        process(response)
      %HTTPoison.AsyncEnd{} -> IO.puts "END"
    end
  end
end
