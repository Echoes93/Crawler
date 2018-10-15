defmodule Crawler.Parser do
  def parse_tags(input), do: parse_tags(input, [], "")
  def parse_tags("", list, buffer), do: {Enum.reverse(list), buffer}

  def parse_tags(<<codepoint>> <> rest, list, buffer) do
    case value(codepoint) do
      :open_token -> parse_tags(rest, append_token(list, buffer), <<codepoint>>)
      :close_token -> parse_tags(rest, [buffer <> <<codepoint>> | list], "")
      :data -> parse_tags(rest, list, buffer <> <<codepoint>>)
    end
  end

  defp value(60), do: :open_token
  defp value(62), do: :close_token
  defp value(_), do: :data

  defp append_token(list, ""), do: list
  defp append_token(list, token), do: [token | list]
end
