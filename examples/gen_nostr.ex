defmodule NostrClient do
  @moduledoc false

  require Logger
  use GenNostr

  def start_link(args) do
    GenNostr.start_link(__MODULE__, args, name: __MODULE__)
  end

  # Callbacks

  @impl GenNostr
  def init(args) do
    relays = Keyword.get(args, :relays, [])
    options = Keyword.get(args, :options, [])

    Enum.each(relays, &GenNostr.add_relay(&1, options))

    {:ok, %{}}
  end

  @impl GenNostr
  def handle_connect(relay, state) do
    Logger.info("Connected to relay: #{inspect(relay.url)}")

    [
      "REQ",
      "1234567890abcdefg",
      %{"kinds" => [1, 6], "since" => 1_678_384_318, "until" => 1_678_387_918, "limit" => 1}
    ]
    |> Jason.encode!()
    |> GenNostr.send_message(relay.url)

    {:ok, state}
  end

  @impl GenNostr
  def handle_disconnect(reason, relay, state) do
    Logger.info("Disconnected from relay: #{inspect(relay.url)} - #{inspect(reason)}")

    case reason do
      {:remove_relay, _} -> Logger.info("Don't reconnect")
      _ -> GenNostr.reconnect(relay)
    end

    {:ok, state}
  end

  @impl GenNostr
  def handle_error(reason, relay, state) do
    Logger.info("Error from relay: #{inspect(relay.url)} - #{inspect(reason)}")
    {:ok, state}
  end

  @impl GenNostr
  def handle_event(message, relay, state) do
    Logger.info("#{message} - #{inspect(relay.url)}")
    {:ok, state}
  end

  @impl GenNostr
  def handle_notice(message, relay, state) do
    Logger.info("#{message} - #{inspect(relay.url)}")
    {:ok, state}
  end

  @impl GenNostr
  def handle_eose(message, relay, state) do
    Logger.info("#{message} - #{inspect(relay.url)}")
    {:ok, state}
  end

  @impl GenNostr
  def handle_ok(message, relay, state) do
    Logger.info("#{message} - #{inspect(relay.url)}")
    {:ok, state}
  end

  @impl GenNostr
  def handle_auth(message, relay, state) do
    Logger.info("#{message} - #{inspect(relay.url)}")
    {:ok, state}
  end
end
