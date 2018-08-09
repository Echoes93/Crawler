defmodule Crawler.Parser do
  def test, do: parse("ASDF #LONDON IS THE $CAPITAL$ OF _GREAT BRITAIN_ \%")

  def parse(input), do: parse(input, [], "")

  def parse("", list, buffer), do: [buffer | list]

  def parse(<<codepoint :: utf8, rest :: binary>>, list, buffer) do
    case value(codepoint) do
      :open_token -> parse(rest, [buffer | list], <<codepoint>>)
      :close_token -> parse(rest, [buffer <> <<codepoint>> | list], "")
      :data -> parse(rest, list, buffer <> <<codepoint>>)
    end
  end

  defp value(60), do: :open_token
  defp value(62), do: :close_token
  defp value(_), do: :data
end
