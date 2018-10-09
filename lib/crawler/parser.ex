defmodule Crawler.Parser do
  def parse_tags(input), do: parse_tags(input, [], "")

  def parse_tags("", list, buffer), do: {Enum.reverse(list), buffer}

  def parse_tags(<<codepoint :: utf8, rest :: binary>>, list, buffer) do
    case value(codepoint) do
      :open_token -> parse_tags(rest, [buffer | list], <<codepoint>>)
      :close_token -> parse_tags(rest, [buffer <> <<codepoint>> | list], "")
      :data -> parse_tags(rest, list, buffer <> <<codepoint>>)
    end
  end

  defp value(60), do: :open_token
  defp value(62), do: :close_token
  defp value(_), do: :data
end
