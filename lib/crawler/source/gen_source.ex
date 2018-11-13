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
