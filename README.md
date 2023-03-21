# GenNostr

GenNostr is a low level websocket client that implements the Nostr transport
protocol and uses the [mint web socket](https://github.com/elixir-mint/mint_web_socket)

This design is based on ideas from [slipstream](https://github.com/NFIBrokerage/slipstream)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gen_socket` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_nostr, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/gen_nostr>.
