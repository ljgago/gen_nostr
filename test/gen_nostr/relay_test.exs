defmodule GenNostr.RelayTest do
  use ExUnit.Case, async: true

  alias GenNostr.Relay

  test "normalize url" do
    inputs = [
      "ws://relay.com",
      "wss://relay.com//ws",
      "wss://relay.com//ws/"
    ]
    expected = [
      "ws://relay.com/",
      "wss://relay.com/ws",
      "wss://relay.com/ws"
    ]

    result = Enum.map(inputs, &Relay.normalize_url(&1))

    assert result == expected
  end
end

