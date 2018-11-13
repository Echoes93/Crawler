defmodule Crawler.FileSourceTest do
  use ExUnit.Case
  alias Crawler.FileSource

  @valid_path "/test/fixtures/example.html"
  @invalid_path "/test/fixture/nonexistentfile"

  describe "open/1" do
    test "returns {:ok, io_device} if given path is valid" do
      path = File.cwd!() <> @valid_path

      assert {:ok, io_device} = FileSource.open(path)
      assert is_pid(io_device)

      close_test_file(io_device)
    end

    test "returns {:error, reason} tuple if given path is invalid or file with that path doesn't exist" do
      path = File.cwd!() <> @invalid_path

      assert {:error, _} = FileSource.open(path)
    end

    test "raises if non binary() or Path.t() argument were given" do
      bad_arg = %{}

      assert_raise ArgumentError, "FileSource.open/1 expects a binary or a Path.t(), got: #{inspect(bad_arg)}", fn ->
        FileSource.open(bad_arg)
      end
    end
  end

  describe "next/1" do
    test "returns {:ok, data} for given io_device" do
      io_device = open_test_file()

      assert {:ok, data} = FileSource.next(io_device)
      assert is_binary(data)

      close_test_file(io_device)
    end

    test "raises if non io_device argument were given" do
      bad_arg = %{}
      assert_raise ArgumentError, "FileSource.next/1 expects a pid (io_device()), got: #{inspect(bad_arg)}", fn ->
        FileSource.next(bad_arg)
      end
    end

    # If :all parameter passed to IO.read, :eof will be never returned, which is not ours case
    # https://hexdocs.pm/elixir/IO.html#read/2
    test "returns {:stop, :eof} if reached end of file" do
      io_device = open_test_file()
      IO.read(io_device, 999999)

      assert {:stop, :eof} = FileSource.next(io_device)

      close_test_file(io_device)
    end
  end

  describe "close/1" do
    test "closes given io_device, if one exists" do
      io_device = open_test_file()

      assert Process.alive?(io_device)
      assert :ok = FileSource.close(io_device)
      refute Process.alive?(io_device)
    end

    test "raises if non io_device argument were given" do
      bad_arg = %{}
      assert_raise ArgumentError, "FileSource.close/1 expects a pid (io_device()), got: #{inspect(bad_arg)}", fn ->
        FileSource.close(bad_arg)
      end
    end
  end


  defp open_test_file, do: File.open!(File.cwd!() <> @valid_path)
  defp close_test_file(io_device), do: File.close(io_device)
end
