defmodule Crawler.Stream do
  alias Crawler.Parser

  def get_tree(uri, opts \\ []) do
    source_mod = Keyword.get(opts, :source_mod, Crawler.HTTPSource)

    uri
    |> get_stream(source_mod)
    |> parse_tags
    |> assemble_tree
  end


  defp get_stream(uri, source_mod) do
    Stream.resource(
      fn ->
        case source_mod.open(uri) do
          {:ok, ref} ->
            ref
          {:error, reason} ->
            raise "#{reason}"
        end
      end,
      fn ref ->
        case source_mod.next(ref) do
          {:ok, data} ->
            {[data], ref}
          {:stop, _reason} ->
            {:halt, ref}
          {:error, reason} ->
            raise "#{reason}"
        end
      end,
      fn ref -> source_mod.close(ref) end)
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
