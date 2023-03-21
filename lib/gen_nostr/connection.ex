defmodule GenNostr.Connection do
  @moduledoc false

  use GenServer

  alias GenNostr.Connection.{ControlFlow, State}
  alias GenNostr.{Commands, Relay}

  def start_link(module, relay) do
    GenServer.start_link(
      __MODULE__,
      {module, relay},
      name: {:via, Registry, {GenNostr.ConnectionRegistry, relay.url, nil}}
    )
  end

  def execute(command) do
    Commands.route_command(command)
  end

  @impl GenServer
  def init({module, relay}) do
    uptime = DateTime.utc_now() |> DateTime.to_unix()
    relay = Relay.update(relay, uptime: uptime)

    state =
      State.new(
        module: module,
        relay: relay
      )

    {:ok, state, {:continue, :connect}}
  end

  @impl GenServer
  def handle_continue(:connect, state) do
    ControlFlow.handle_connect(state)
  end

  @impl GenServer
  def handle_info(message, state) do
    ControlFlow.handle_info(message, state)
  end

  @impl GenServer
  def handle_cast(message, state) do
    ControlFlow.handle_cast(message, state)
  end

  # @impl GenServer
  # def terminate(reason, state) do
  #   ControlFlow.terminate(reason, state)
  # end
end
