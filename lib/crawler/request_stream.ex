defmodule Crawler.Request.Stream do
  alias Crawler.Parser

  def get(url) do
    url
    |> get_stream
    |> parse_tags
    |> assemble_tree
  end


  defp get_stream(url) do
    Stream.resource(
      fn ->
        case :hackney.get(url, [], "", [follow_redirect: true]) do
          {:ok, _status, _headers, body_ref} -> body_ref
          {:error, reason} -> raise "#{reason}"
        end
      end,
      fn ref ->
        case :hackney.stream_body(ref) do
          {:ok, data} -> {[data], ref}
          :done -> {:halt, ref}
        end
      end,
      fn _ -> IO.inspect(self()) end)
  end

  defp parse_tags(request_stream) do
    Stream.transform(
      request_stream,
      "",
      fn chunk, remainer -> Parser.parse_tags(remainer <> chunk) end)
  end

  defp assemble_tree(tag_stream) do
    Enum.flat_map(tag_stream, &:mochiweb_html.tokens(&1))
    |> :mochiweb_html.parse_tokens()
  end
end
