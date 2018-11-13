defmodule Crawler.HTTPSource do
  @behaviour Crawler.GenSource

  def open(url) when is_binary(url) do
    case :hackney.get(url, [], "", [follow_redirect: true]) do
      {:ok, _status, _headers, ref} ->
        {:ok, ref}
      {:error, reason} ->
        {:error, reason}
    end
  end
  def open(path), do: raise ArgumentError, "HTTPSource.open/1 expects a binary, got: #{inspect(path)}"

  def next(ref) when is_reference(ref) do
    case :hackney.stream_body(ref) do
      {:error, reason} ->
        {:error, reason}
      :stop ->
        {:stop, :eof}
      {:ok, data} ->
        {:ok, data}
    end
  end
  def next(ref), do: raise ArgumentError, "HTTPSource.next/1 expects a reference, got: #{inspect(ref)}"

  def close(_), do: :ok
end
