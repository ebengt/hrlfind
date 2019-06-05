# Hrlfind

Hrlfind should find the full path to an Erlang hrl file, starting from a line of source.
 A rebar build system is assumed.
 Example:
   hrlfind -include( "include/diameter_3gpp_ts32_299.hrl" ).
 should return
   "/path/_build/default/lib/app/include/diameter_3gpp_ts32_299.hrl"

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hrlfind` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hrlfind, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/hrlfind](https://hexdocs.pm/hrlfind).

