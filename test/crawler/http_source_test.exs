defmodule Crawler.HTTPSourceTest do
  use ExUnit.Case
  alias Crawler.HTTPSource

  @valid_url "example.com"
  @invalid_url "\\/invalid%"

  describe "open/1" do
    test "returns {:ok, ref} if given url is valid" do
      assert {:ok, ref} = HTTPSource.open(@valid_url)

      close_client(ref)
    end

    test "returns {:error, reason} if given url is invalid" do
      assert {:error, _reason} = HTTPSource.open(@invalid_url)
    end

    test "raises if non binary argument were given" do
      bad_arg = %{}

      assert_raise ArgumentError, "HTTPSource.open/1 expects a binary, got: #{inspect(bad_arg)}", fn ->
        HTTPSource.open(bad_arg)
      end
    end
  end

  describe "next/1" do
    test "returns {:ok, data} for given client ref" do
      ref = open_client()

      assert {:ok, data} = HTTPSource.next(ref)
      assert is_binary(data)
    end

    test "raises if non reference argument were given" do
      bad_arg = %{}

      assert_raise ArgumentError, "HTTPSource.next/1 expects a reference, got: #{inspect(bad_arg)}", fn ->
        HTTPSource.next(bad_arg)
      end
    end

    # test "returns {:stop, :eof} if reached end of file" do

    # end

    test "returns {:error, :req_not_found} if reference is not valid (connection closed)" do
      ref = open_client()
      close_client(ref)

      assert {:error, :req_not_found} = HTTPSource.next(ref)
    end
  end


  defp open_client() do
    {_,_,_,ref} = :hackney.get(@valid_url, [], "", [follow_redirect: true])
    ref
  end
  defp close_client(ref), do: :hackney.close(ref)
end
