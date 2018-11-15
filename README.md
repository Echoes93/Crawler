# Crawler

This project is my personal playground with Elixir [`Streams`](https://hexdocs.pm/elixir/Stream.html) and [`Stages`](https://hexdocs.pm/gen_stage/GenStage.html). If you are looking for Elixir based web crawler - there is one [Crawler](https://github.com/fredwu/crawler), which you might want to use.

## Abstract
The main goal of project is to measure performance difference between `Stream` and `GenStage` when processing structured data (i.e. html/xml document).  

There are 2 modules of interest here - `Crawler.Stage` and `Crawler.Stream`. Both export `get_tree` function, which takes url/path, and keyword-list of options. If no options given - it is assumed that given parameter is url, and will perform http request to it. Then it will stream down the response and transform it into tree structure. The core difference is that `Crawler.Stream` will use Streams for that, so all transformation steps will be performed within single process, whereas `Crawler.Stage` performs different steps in different processes. In both cases every step works with chunked data, rather than whole document, with the exception of `assemble_tree` step - it relies on [`:mochiweb_html`](https://github.com/mochi/mochiweb) and expects whole list of html tokens to build the tree. However, this particularity seriously affects performance and I plan to build my own naive version of asynchronous tree assembler, that could work with chunked data.

## Performance benchmark

Benchee performance test `Crawler.Stream.get_tree` vs `Crawler.Stage.get_tree` sourcing `/benchmarks/RFC7540.html` file (279KB, 284759 symbols). The difference grows with document size in favor of `Crawler.Stage`. 

Also, given that assemble tree step is synchronous, there is no real difference between `Streams` and just retrieving whole data using `File.read` and transforming it synchronously with `:mochiweb_html`.
```
Operating System: Windows"
CPU Information: Intel(R) Core(TM) i7-7500U CPU @ 2.70GHz
Number of Available Cores: 4
Available memory: 15.63 GB
Elixir 1.7.1
Erlang 21.0.1

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ╬╝s
parallel: 1
inputs: none specified
Estimated total run time: 14 s


Benchmarking Stage...
Benchmarking Stream...

Name             ips        average  deviation         median         99th %
Stage          37.37       26.76 ms    ┬▒48.73%          31 ms          62 ms
Stream         20.33       49.18 ms    ┬▒12.35%          47 ms          63 ms

Comparison:
Stage          37.37
Stream         20.33 - 1.84x slower
```