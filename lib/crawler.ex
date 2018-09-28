defmodule Crawler do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Crawler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def test do
    {_,_,_, body_ref} = :hackney.get("google.com", [], "", [follow_redirect: true])
    {:ok, body} = :hackney.body body_ref
    t = :mochiweb_html.parse body
    IO.inspect(t)
  end
end
