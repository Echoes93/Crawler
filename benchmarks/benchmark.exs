uri = __DIR__ <> "/RFC7540.html"
opts = [source_mod: Crawler.FileSource]

Benchee.run(%{
  "Stream" => fn -> Crawler.Stream.get_tree(uri, opts) end,
  "Stage" => fn -> Crawler.Stage.get_tree(uri, opts) end
})
