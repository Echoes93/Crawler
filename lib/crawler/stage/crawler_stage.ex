defmodule Crawler.Stage do
  alias Crawler.Stage

  def get_tree(uri, opts \\ []) do
    source_mod = Keyword.get(opts, :source_mod, Crawler.HTTPSource)
    callback = Keyword.get(opts, :callback, &(&1))

    {:ok, producer} = Stage.Producer.start_link(uri, source_mod)
    {:ok, parse_stage} = Crawler.Stage.ParseTags.start_link()
    {:ok, assemble_stage} = Crawler.Stage.AssembleTree.start_link(callback)


    GenStage.sync_subscribe(assemble_stage, to: parse_stage, max_demand: 10, min_demand: 5)
    GenStage.sync_subscribe(parse_stage, to: producer, max_demand: 10, min_demand: 5)
  end
end
