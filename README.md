# Crawler

This project is my personal study on Elixirs `Streams` and `Stages`. If you are looking for Elixir based web crawler - there is one [Crawler](https://github.com/fredwu/crawler), which you might want to use.

## Performance benchmark

Benchee performance test `Crawler.Stream.get_tree` vs `Crawler.Stage.get_tree` sourcing `/benchmarks/RFC7540.html` file. 
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