defmodule Crawler.FileSource do
  @behaviour Crawler.GenSource

  def open(path) when is_binary(path), do: File.open(path)
  def open(path), do: raise ArgumentError, "FileSource.open/1 expects a binary or a Path.t(), got: #{inspect(path)}"

  def next(io_device) when is_pid(io_device) do
    case IO.read(io_device, 5000) do
      {:error, reason} ->
        {:error, reason}
      :eof ->
        {:stop, :eof}
      data ->
        {:ok, data}
    end
  end
  def next(io_device), do: raise ArgumentError, "FileSource.next/1 expects a pid (io_device()), got: #{inspect(io_device)}"

  def close(io_device) when is_pid(io_device), do: File.close(io_device)
  def close(io_device), do: raise ArgumentError, "FileSource.close/1 expects a pid (io_device()), got: #{inspect(io_device)}"
end
