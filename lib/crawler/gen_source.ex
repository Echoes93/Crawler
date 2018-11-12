defmodule Crawler.GenSource do
  @moduledoc """
    Behaviour module to provide unified interface for stream sources.
  """

  @type source ::
    binary()
    | URI.t()
    | Path.t()

  @type ref :: term()
  @type stream_data :: binary()

  @callback open(uri :: source) ::
    {:ok, ref}
    | {:error, reason :: term()}

  @callback next(ref) ::
    {:ok, stream_data()}
    | {:stop, reason :: term()}

  @callback close(ref) :: term()
end

defmodule Crawler.HTTPSource do
  @behaviour Crawler.GenSource

  def open(url) do
    case :hackney.get(url, [], "", [follow_redirect: true]) do
      {:ok, _status, _headers, ref} ->
        {:ok, ref}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def next(ref) do
    case :hackney.stream_body(ref) do
      {:error, reason} ->
        {:error, reason}
      :stop ->
        {:stop, :eof}
      {:ok, data} ->
        {:ok, data}
    end
  end

  def close(_), do: nil
end

defmodule Crawler.FileSource do
  @behaviour Crawler.GenSource

  def open(path), do: File.open(path)

  def next(ref) do
    case IO.read(ref, 5000) do
      {:error, reason} ->
        {:error, reason}
      :eof ->
        {:stop, :eof}
      data ->
        {:ok, data}
    end
  end

  def close(ref), do: File.close(ref)
end
